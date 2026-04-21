# Sprint 10 — Email Alert System
## Deployment Guide

---

## Files in this sprint

| File | Purpose |
|------|---------|
| `sprint10_step1_db.sql` | DB tables + compliance function |
| `email-alerts/index.ts` | Edge function (all 8 alert types) |
| `sprint10_step2_cron.sql` | pg_cron scheduled jobs |

---

## Step 1 — Run the database migration

1. Open **Supabase → SQL Editor**
2. Paste the full contents of **`sprint10_step1_db.sql`**
3. Click **Run**
4. Verify: no errors (yellow warnings about existing objects are fine)

**What this creates:**
- `email_log` table with unique deduplication index
- `property_insurance` table with RLS
- `mtd_periods` table (scaffolded, ready for post-launch accounting module)
- `next_rent_due` column added to `tenancies` if missing
- `get_compliance_score(landlord_id)` PostgreSQL function
- `purge_old_email_logs()` cleanup function

---

## Step 2 — Deploy the edge function

### 2a. Create the function folder

In your project root, create this folder structure:
```
supabase/
  functions/
    email-alerts/
      index.ts        ← paste email-alerts-index.ts content here
```

### 2b. Set environment secret

In **Supabase → Project Settings → Edge Functions → Secrets**, add:
```
RESEND_API_KEY = re_xxxxxxxxxxxxxxxxxxxxxxxx
```
(It already exists from your ai-proxy function — copy the same value)

### 2c. Deploy via PowerShell (run each line separately)

```powershell
cd C:\path\to\your\rentsafeai

npx supabase login

npx supabase functions deploy email-alerts --project-ref mahtcfukgzbonwibtsxz
```

> **Note:** The `--no-verify-jwt` flag is NOT used here. The cron jobs
> authenticate with the service role key in the Authorization header.

### 2d. Verify deployment

- Go to **Supabase → Edge Functions**
- You should see `email-alerts` listed and active
- Click it → check the logs panel is available

---

## Step 3 — Set up cron jobs

1. Open **`sprint10_step2_cron.sql`**
2. **Replace `YOUR_SERVICE_ROLE_KEY`** with your actual service role key
   - Find it: Supabase → Settings → API → `service_role` (secret key)
   - Replace both occurrences (daily job + weekly job)
3. Paste the full SQL into **Supabase → SQL Editor**
4. Click **Run**
5. Verify with the SELECT at the bottom — you should see 3 rows:
   - `rentsafeai-daily-alerts` — `0 9 * * *`
   - `rentsafeai-weekly-summary` — `0 8 * * 1`
   - `rentsafeai-monthly-purge` — `0 2 1 * *`

> **Security:** The service role key in the SQL is stored inside Supabase's
> own infrastructure (cron.job table). It never leaves your Supabase project.

---

## Step 4 — Test immediately (manual trigger)

In **Supabase → SQL Editor**, run the manual test at the bottom of
`sprint10_step2_cron.sql` (uncomment those lines first).

Then check:
1. **Edge Function logs** — Supabase → Edge Functions → email-alerts → Logs
2. **email_log table** — should have rows for any alerts that fired
3. **Your inbox** — if test data exists that meets alert conditions

---

## Step 5 — Verify test data exists

For alerts to fire during testing, you need data in the right state.
Here's a quick test data SQL you can run in SQL Editor:

```sql
-- Add a test certificate expiring in 7 days
-- (replace 'YOUR_PROPERTY_ID' with a real property ID from your properties table)

INSERT INTO certificates (property_id, cert_type, expiry_date, status)
SELECT
  id as property_id,
  'Gas Safety Certificate',
  CURRENT_DATE + INTERVAL '7 days',
  'valid'
FROM properties
LIMIT 1;

-- View the email_log after triggering:
SELECT * FROM email_log ORDER BY sent_at DESC LIMIT 20;
```

---

## Alert types & deduplication summary

| Alert | Trigger | Dedup key | Re-fires |
|-------|---------|-----------|---------|
| Cert expiring | 60/30/14/7 days before | `cert_{id}_{days}d` | Never (once per window) |
| Rent overdue | 1 day after due date | `rent_overdue_{id}_{date}` | Never (once per due date) |
| Maintenance overdue | 7+ days no update | `maint_overdue_{id}_{week}` | Weekly while unresolved |
| Awaab's Law | 14+ days open + damp keyword | `awaab_{id}_{week}` | Weekly while unresolved |
| MTD deadline | 30/14/7 days before | `mtd_{id}_{days}d` | Never (once per window) |
| Insurance expiry | 60/30 days before | `insurance_{id}_{days}d` | Never (once per window) |
| Compliance score | Score drops below 70% | `compliance_{landlord}_{date}` | Daily while below threshold |
| Weekly summary | Every Monday | `summary_{landlord}_{week}` | Weekly (new key each week) |

---

## Cron schedule

| Job | Schedule | When |
|-----|---------|------|
| Daily alerts | `0 9 * * *` | 09:00 UTC = 10:00 BST / 09:00 GMT |
| Weekly summary | `0 8 * * 1` | 08:00 UTC Mondays |
| Log purge | `0 2 1 * *` | 02:00 UTC on 1st of month |

---

## Monitoring

**Check job history** (run in SQL Editor):
```sql
SELECT
  jrd.jobid,
  j.jobname,
  jrd.start_time,
  jrd.end_time,
  jrd.status,
  jrd.return_message
FROM cron.job_run_details jrd
JOIN cron.job j ON j.jobid = jrd.jobid
WHERE j.jobname LIKE 'rentsafeai%'
ORDER BY jrd.start_time DESC
LIMIT 20;
```

**Check what's been sent:**
```sql
SELECT
  alert_type,
  COUNT(*) as sent_count,
  MAX(sent_at) as last_sent
FROM email_log
GROUP BY alert_type
ORDER BY last_sent DESC;
```

**Clear test data (if needed):**
```sql
-- Only do this in dev, never prod
TRUNCATE email_log;
```

---

## Outstanding items (from previous sessions)

| # | Item | Status |
|---|------|--------|
| 1 | HTTPS "Not secure" | GitHub Pages SSL — still pending |
| 2 | Resend SPF record | Email may be unreliable until resolved |
| 3 | RRA PDF attachment | Need to upload GOV.UK PDF |
| 4 | Section 8 → Form 3A | UX handoff still needed |

---

## Next sprint prompt

> **Sprint 11 — Tenant Portal**
>
> You are my senior web developer helping me build RentSafeAI — a UK landlord SaaS.
> Live: rentsafeai.co.uk | GitHub: github.com/sddhawan79-lang/rentsafeai
> Supabase: mahtcfukgzbonwibtsxz.supabase.co
> Deploy: PowerShell — run each command separately (&& does not work)
>
> Today we are building Sprint 11 — the Tenant Portal.
> Each tenancy gets a unique URL (no login required).
> Tenants can: view their tenancy details, report a maintenance issue
> (with photo upload), view open jobs, and download their latest certificates.
> Use the existing maintenance_jobs and certificates tables.
> All submissions create a row in maintenance_jobs and trigger the landlord
> email alert system from Sprint 10.
