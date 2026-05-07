-- ═══════════════════════════════════════════════════════════════════════════
-- Sprint 13 — User Profile & Stripe Subscriptions
-- Run in: Supabase → SQL Editor
-- Order: Run this file in full (single execution)
-- ═══════════════════════════════════════════════════════════════════════════


-- ── 1. user_profiles ─────────────────────────────────────────────────────────
--    Stores optional personal details for each logged-in landlord.
--    Primary key matches auth.users(id) — one row per user.

CREATE TABLE IF NOT EXISTS user_profiles (
  id           uuid        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name    text,
  phone        text,
  company_name text,
  address      text,
  utr_number   text,        -- 10-digit Unique Taxpayer Reference (MTD / HMRC)
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Users may only read/write their own profile row
CREATE POLICY "user_profiles: select own"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "user_profiles: insert own"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "user_profiles: update own"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);


-- ── 2. stripe_subscriptions ───────────────────────────────────────────────────
--    One row per user (UNIQUE on user_id). Written by the stripe-webhook edge
--    function (service role — bypasses RLS). Read by the profile page (user JWT).

CREATE TABLE IF NOT EXISTS stripe_subscriptions (
  id                      uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  stripe_customer_id      text,
  stripe_subscription_id  text,
  stripe_price_id         text,
  plan_name               text,        -- 'starter' | 'landlord' | 'portfolio'
  status                  text,        -- 'active' | 'canceled' | 'past_due' | 'trialing' | 'incomplete'
  current_period_start    timestamptz,
  current_period_end      timestamptz,
  cancel_at_period_end    boolean      DEFAULT false,
  created_at              timestamptz  DEFAULT now(),
  updated_at              timestamptz  DEFAULT now(),

  -- Enforce one subscription row per user (upsert target)
  CONSTRAINT stripe_subscriptions_user_id_key UNIQUE (user_id)
);

ALTER TABLE stripe_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can read their own subscription (to show plan on profile page)
CREATE POLICY "stripe_subscriptions: select own"
  ON stripe_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT / UPDATE / DELETE: service role only (webhook function)
-- No additional policies needed — service role bypasses RLS


-- ── 3. Helpful index ──────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS stripe_subscriptions_stripe_subscription_id_idx
  ON stripe_subscriptions (stripe_subscription_id);
