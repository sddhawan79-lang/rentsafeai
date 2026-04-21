-- ============================================================
-- SPRINT 10 — Step 1: Database Setup
-- Run this in Supabase SQL Editor (rentsafeai project)
-- Safe to run multiple times (idempotent)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. EMAIL LOG TABLE
-- Prevents duplicate alert sends. Central dedup store.
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS email_log (
  id             uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  landlord_id    uuid        REFERENCES auth.users(id) ON DELETE CASCADE,
  alert_type     text        NOT NULL,
  reference_key  text        NOT NULL,  -- unique key per alert instance
  recipient_email text,
  sent_at        timestamptz DEFAULT now(),
  metadata       jsonb       DEFAULT '{}'
);

-- Unique constraint: never send the same alert twice
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE indexname = 'email_log_unique_alert'
  ) THEN
    CREATE UNIQUE INDEX email_log_unique_alert
    ON email_log (landlord_id, alert_type, reference_key);
  END IF;
END $$;

-- Index for time-based cleanup queries
CREATE INDEX IF NOT EXISTS email_log_sent_at_idx ON email_log (sent_at);
CREATE INDEX IF NOT EXISTS email_log_landlord_idx ON email_log (landlord_id);


-- ────────────────────────────────────────────────────────────
-- 2. PROPERTY INSURANCE TABLE
-- Tracks building/landlord insurance policies per property
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS property_insurance (
  id             uuid   DEFAULT gen_random_uuid() PRIMARY KEY,
  property_id    uuid   REFERENCES properties(id) ON DELETE CASCADE,
  provider       text,
  policy_number  text,
  policy_type    text   DEFAULT 'building',  -- building | landlord | contents
  expiry_date    date   NOT NULL,
  premium_amount numeric(10,2),
  notes          text,
  created_at     timestamptz DEFAULT now(),
  updated_at     timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS property_insurance_property_idx 
  ON property_insurance (property_id);
CREATE INDEX IF NOT EXISTS property_insurance_expiry_idx 
  ON property_insurance (expiry_date);

-- RLS
ALTER TABLE property_insurance ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Landlords manage own insurance" ON property_insurance;
CREATE POLICY "Landlords manage own insurance"
  ON property_insurance
  FOR ALL
  USING (
    property_id IN (
      SELECT id FROM properties WHERE landlord_id = auth.uid()
    )
  );


-- ────────────────────────────────────────────────────────────
-- 3. MTD PERIODS TABLE (scaffolded — not built yet)
-- Each row = one MTD submission period for a landlord.
-- The accounting module will populate this post-launch.
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS mtd_periods (
  id                  uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  landlord_id         uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  period_start        date NOT NULL,
  period_end          date NOT NULL,
  submission_deadline date NOT NULL,   -- HMRC deadline (usually 1 month after period end)
  status              text DEFAULT 'pending',  -- pending | submitted | overdue
  tax_year            text,             -- e.g. "2025-26"
  quarter             int,              -- 1–4
  created_at          timestamptz DEFAULT now(),
  updated_at          timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS mtd_periods_landlord_idx ON mtd_periods (landlord_id);
CREATE INDEX IF NOT EXISTS mtd_periods_deadline_idx ON mtd_periods (submission_deadline);

ALTER TABLE mtd_periods ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Landlords manage own MTD" ON mtd_periods;
CREATE POLICY "Landlords manage own MTD"
  ON mtd_periods FOR ALL
  USING (landlord_id = auth.uid());


-- ────────────────────────────────────────────────────────────
-- 4. ENSURE TENANCIES TABLE HAS next_rent_due COLUMN
-- If your tenancies table already has this, this is a no-op.
-- ────────────────────────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'tenancies' AND column_name = 'next_rent_due'
  ) THEN
    ALTER TABLE tenancies ADD COLUMN next_rent_due date;
    COMMENT ON COLUMN tenancies.next_rent_due IS 
      'Next expected rent payment date. Updated after each payment confirmed.';
  END IF;
END $$;


-- ────────────────────────────────────────────────────────────
-- 5. HELPER: Compliance score function
-- Returns a 0–100 score per property based on cert validity.
-- Used by the compliance alert (score < 70 triggers email).
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_compliance_score(p_landlord_id uuid)
RETURNS numeric
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_expected  int;
  total_valid     int;
  score           numeric;
BEGIN
  -- Count properties owned by this landlord
  SELECT COUNT(*) INTO total_expected
  FROM properties
  WHERE landlord_id = p_landlord_id;

  -- No properties = 100 (nothing to fail)
  IF total_expected = 0 THEN RETURN 100; END IF;

  -- Count properties that have ALL mandatory certs valid (not expired)
  SELECT COUNT(DISTINCT p.id) INTO total_valid
  FROM properties p
  WHERE p.landlord_id = p_landlord_id
    AND (
      -- At least one gas safety cert valid
      EXISTS (
        SELECT 1 FROM certificates c
        WHERE c.property_id = p.id
          AND c.cert_type ILIKE '%gas%'
          AND c.expiry_date > now()
      )
      OR NOT EXISTS (
        SELECT 1 FROM certificates c
        WHERE c.property_id = p.id
          AND c.cert_type ILIKE '%gas%'
      )
    );

  -- Simple ratio: properties with no overdue certs vs total
  SELECT COUNT(DISTINCT p.id) INTO total_valid
  FROM properties p
  WHERE p.landlord_id = p_landlord_id
    AND NOT EXISTS (
      SELECT 1 FROM certificates c
      WHERE c.property_id = p.id
        AND c.expiry_date < now()
        AND c.cert_type NOT ILIKE '%epc%'  -- EPC doesn't affect tenancy legality immediately
    );

  score := ROUND((total_valid::numeric / total_expected::numeric) * 100, 1);
  RETURN score;
END;
$$;


-- ────────────────────────────────────────────────────────────
-- 6. CLEANUP: Auto-purge email_log entries older than 18 months
-- Keeps the table lean.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION purge_old_email_logs()
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  DELETE FROM email_log WHERE sent_at < now() - interval '18 months';
$$;


-- ============================================================
-- DONE. Proceed to sprint10_step2_cron.sql
-- ============================================================
