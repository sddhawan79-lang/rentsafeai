-- ============================================================
-- SPRINT 10 — Step 2: pg_cron Scheduled Jobs
-- Run this in Supabase SQL Editor AFTER:
--   1. sprint10_step1_db.sql has been executed
--   2. email-alerts edge function has been deployed
--
-- BEFORE RUNNING: Replace YOUR_SERVICE_ROLE_KEY below
-- (Settings → API → service_role key — keep secret)
-- ============================================================


-- ── Enable pg_cron if not already enabled ────────────────────
-- (This is usually already enabled on Supabase Pro/paid plans)
-- If you see "extension already exists" — that's fine, ignore it.

CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;  -- needed for net.http_post


-- ── Remove old jobs if re-running this script ────────────────
SELECT cron.unschedule('rentsafeai-daily-alerts')   WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'rentsafeai-daily-alerts');
SELECT cron.unschedule('rentsafeai-weekly-summary') WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'rentsafeai-weekly-summary');
SELECT cron.unschedule('rentsafeai-monthly-purge')  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'rentsafeai-monthly-purge');


-- ════════════════════════════════════════════════════════════
-- JOB 1: DAILY ALERT CHECK — every day at 09:00 UTC
--
-- Checks all 7 daily alert types:
--   cert expiry · rent overdue · maintenance overdue
--   awaab law · mtd deadline · insurance expiry · compliance score
-- ════════════════════════════════════════════════════════════

SELECT cron.schedule(
  'rentsafeai-daily-alerts',
  '0 9 * * *',   -- 09:00 UTC daily (10:00 BST / 09:00 GMT)
  $$
  SELECT net.http_post(
    url     := 'https://mahtcfukgzbonwibtsxz.supabase.co/functions/v1/email-alerts',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
    ),
    body    := '{"type":"daily"}'::jsonb
  ) AS request_id;
  $$
);


-- ════════════════════════════════════════════════════════════
-- JOB 2: WEEKLY SUMMARY — every Monday at 08:00 UTC
--
-- Sends the Monday portfolio summary email to all landlords.
-- Day-of-week: 1 = Monday in cron syntax
-- ════════════════════════════════════════════════════════════

SELECT cron.schedule(
  'rentsafeai-weekly-summary',
  '0 8 * * 1',   -- 08:00 UTC every Monday
  $$
  SELECT net.http_post(
    url     := 'https://mahtcfukgzbonwibtsxz.supabase.co/functions/v1/email-alerts',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
    ),
    body    := '{"type":"weekly_summary"}'::jsonb
  ) AS request_id;
  $$
);


-- ════════════════════════════════════════════════════════════
-- JOB 3: MONTHLY EMAIL LOG PURGE — 1st of each month at 02:00
--
-- Deletes email_log entries older than 18 months.
-- Keeps the table lean and the unique index fast.
-- ════════════════════════════════════════════════════════════

SELECT cron.schedule(
  'rentsafeai-monthly-purge',
  '0 2 1 * *',   -- 02:00 UTC on the 1st of every month
  $$ SELECT purge_old_email_logs(); $$
);


-- ── Verify jobs were created ──────────────────────────────────
SELECT
  jobid,
  jobname,
  schedule,
  command,
  active
FROM cron.job
WHERE jobname LIKE 'rentsafeai%'
ORDER BY jobid;


-- ── To check job run history (after first run): ──────────────
-- SELECT * FROM cron.job_run_details
-- WHERE jobid IN (SELECT jobid FROM cron.job WHERE jobname LIKE 'rentsafeai%')
-- ORDER BY start_time DESC
-- LIMIT 20;


-- ── To temporarily pause a job: ──────────────────────────────
-- UPDATE cron.job SET active = false WHERE jobname = 'rentsafeai-daily-alerts';

-- ── To resume: ───────────────────────────────────────────────
-- UPDATE cron.job SET active = true WHERE jobname = 'rentsafeai-daily-alerts';


-- ════════════════════════════════════════════════════════════
-- MANUAL TEST: Run the edge function immediately
-- (replace YOUR_SERVICE_ROLE_KEY — same key as above)
-- ════════════════════════════════════════════════════════════

-- Test daily alerts:
-- SELECT net.http_post(
--   url     := 'https://mahtcfukgzbonwibtsxz.supabase.co/functions/v1/email-alerts',
--   headers := jsonb_build_object(
--     'Content-Type',  'application/json',
--     'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
--   ),
--   body    := '{"type":"daily"}'::jsonb
-- );

-- Test weekly summary:
-- SELECT net.http_post(
--   url     := 'https://mahtcfukgzbonwibtsxz.supabase.co/functions/v1/email-alerts',
--   headers := jsonb_build_object(
--     'Content-Type',  'application/json',
--     'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
--   ),
--   body    := '{"type":"weekly_summary"}'::jsonb
-- );

-- ============================================================
-- DONE. All 3 cron jobs are now scheduled.
-- ============================================================
