/**
 * stripe-checkout/index.ts
 * ─────────────────────────────────────────────────────────────────────────────
 * Creates a Stripe Checkout Session for the authenticated landlord.
 * Called by the profile page when a user clicks "Subscribe".
 *
 * How it works:
 *   1. Verifies the caller's Supabase JWT
 *   2. Looks up (or creates) a Stripe Customer for this user
 *   3. Creates a Stripe Checkout Session with the chosen plan's Price ID
 *   4. Returns { url } — the profile page redirects the browser to this URL
 *   5. After payment, Stripe redirects to profile.html?success=true
 *   6. stripe-webhook function then fires to record the subscription in DB
 *
 * Secrets required in Supabase Dashboard → Project Settings → Secrets:
 *   STRIPE_SECRET_KEY        sk_test_... (or sk_live_... in production)
 *   STRIPE_PRICE_STARTER     price_...  (Starter £9.99/mo)
 *   STRIPE_PRICE_LANDLORD    price_...  (Landlord £19.99/mo)
 *   STRIPE_PRICE_PORTFOLIO   price_...  (Portfolio £39.99/mo)
 *
 * Deploy command (run from repo root):
 *   Copy this file to supabase/functions/stripe-checkout/index.ts
 *   npx supabase functions deploy stripe-checkout --project-ref mahtcfukgzbonwibtsxz
 * ─────────────────────────────────────────────────────────────────────────────
 */

import Stripe from 'https://esm.sh/stripe@14.21.0?target=deno';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

// ── CONFIG ───────────────────────────────────────────────────────────────────

const STRIPE_SECRET_KEY   = Deno.env.get('STRIPE_SECRET_KEY')!;
const SUPABASE_URL        = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const BASE_URL            = 'https://rentsafeai.co.uk';

/** Maps plan slug → Stripe Price ID (set via Supabase secrets) */
const PRICE_IDS: Record<string, string> = {
  starter:   Deno.env.get('STRIPE_PRICE_STARTER')   ?? '',
  landlord:  Deno.env.get('STRIPE_PRICE_LANDLORD')  ?? '',
  portfolio: Deno.env.get('STRIPE_PRICE_PORTFOLIO') ?? '',
};

const CORS_HEADERS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// ── STRIPE CLIENT ────────────────────────────────────────────────────────────

const stripe = new Stripe(STRIPE_SECRET_KEY, {
  apiVersion: '2024-06-20',
  httpClient: Stripe.createFetchHttpClient(),
});

// ── HANDLER ──────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {

  // Handle browser preflight CORS request
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: CORS_HEADERS });
  }

  try {

    // ── Step 1: Authenticate the caller via Supabase JWT ─────────────────────
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return _err(401, 'Missing Authorization header');
    }

    const token = authHeader.replace('Bearer ', '');
    const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
      auth: { persistSession: false },
    });

    const { data: { user }, error: authError } = await sb.auth.getUser(token);
    if (authError || !user) {
      return _err(401, 'Invalid or expired session token');
    }

    // ── Step 2: Validate the requested plan ──────────────────────────────────
    const body = await req.json().catch(() => ({}));
    const plan: string = body.plan ?? '';

    if (!plan || !(plan in PRICE_IDS)) {
      return _err(400, `Invalid plan "${plan}". Must be: starter | landlord | portfolio`);
    }

    const priceId = PRICE_IDS[plan];
    if (!priceId) {
      return _err(500, `Price ID not configured for plan "${plan}". ` +
        `Set STRIPE_PRICE_${plan.toUpperCase()} in Supabase Edge Function secrets.`);
    }

    // ── Step 3: Retrieve or create Stripe Customer for this user ─────────────
    //    We store the stripe_customer_id in stripe_subscriptions so we can
    //    re-use it on subsequent checkouts rather than creating duplicates.
    const { data: existingSub } = await sb
      .from('stripe_subscriptions')
      .select('stripe_customer_id')
      .eq('user_id', user.id)
      .single();

    let customerId: string | undefined = existingSub?.stripe_customer_id ?? undefined;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email ?? undefined,
        metadata: { supabase_user_id: user.id },
      });
      customerId = customer.id;
    }

    // ── Step 4: Create the Stripe Checkout Session ───────────────────────────
    //    - mode: 'subscription' for recurring billing
    //    - success_url: profile page picks up ?success=true to show confirmation
    //    - cancel_url:  profile page picks up ?canceled=true to show a notice
    //    - metadata.user_id: used by stripe-webhook to identify the Supabase user
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: `${BASE_URL}/profile.html?success=true&plan=${plan}`,
      cancel_url:  `${BASE_URL}/profile.html?canceled=true`,
      metadata: {
        plan,
        user_id: user.id,   // critical — used by stripe-webhook to link to Supabase user
      },
      // Allow promotion codes so users can redeem discount codes at checkout
      allow_promotion_codes: true,
    });

    return new Response(JSON.stringify({ url: session.url }), {
      headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
    });

  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error('[stripe-checkout] Unhandled error:', msg);
    return _err(500, 'Internal server error: ' + msg);
  }
});

// ── HELPER ───────────────────────────────────────────────────────────────────

/** Returns a JSON error response with CORS headers. */
function _err(status: number, message: string): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  });
}
