-- ============================================================
-- SPRINT 10 — Step 1 FIX
-- Handles existing email_log table safely
-- Run this in Supabase SQL Editor
-- ============================================================

-- ── 1. Add missing columns to existing email_log table ───────
ALTER TABLE email_log
  ADD COLUMN IF NOT EXISTS landlord_id    uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS alert_type     text,
  ADD COLUMN IF NOT EXISTS reference_key  text,
  ADD COLUMN IF NOT EXISTS recipient_email text,
  ADD COLUMN IF NOT EXISTS metadata       jsonb DEFAULT '{}';

-- ── 2. Create dedup unique index ─────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS email_log_unique_alert
  ON email_log (landlord_id, alert_type, reference_key);

-- ── 3. Create supporting indexes ─────────────────────────────
CREATE INDEX IF NOT EXISTS email_log_sent_at_idx   ON email_log (sent_at);
CREATE INDEX IF NOT EXISTS email_log_landlord_idx  ON email_log (landlord_id);

-- ── 4. Property insurance table ──────────────────────────────
CREATE TABLE IF NOT EXISTS property_insurance (
  id             uuid   DEFAULT gen_random_uuid() PRIMARY KEY,
  property_id    uuid   REFERENCES properties(id) ON DELETE CASCADE,
  provider       text,
  policy_number  text,
  policy_type    text   DEFAULT 'building',
  expiry_date    date   NOT NULL,
  premium_amount numeric(10,2),
  notes          text,
  created_at     timestamptz DEFAULT now(),
  updated_at     timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS property_insurance_property_idx ON property_insurance (property_id);
CREATE INDEX IF NOT EXISTS property_insurance_expiry_idx   ON property_insurance (expiry_date);

ALTER TABLE property_insurance ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Landlords manage own insurance" ON property_insurance;
CREATE POLICY "Landlords manage own insurance"
  ON property_insurance FOR ALL
  USING (
    property_id IN (
      SELECT id FROM properties WHERE landlord_id = auth.uid()
    )
  );

-- ── 5. MTD periods table (scaffolded) ────────────────────────
CREATE TABLE IF NOT EXISTS mtd_periods (
  id                  uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  landlord_id         uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  period_start        date NOT NULL,
  period_end          date NOT NULL,
  submission_deadline date NOT NULL,
  status              text DEFAULT 'pending',
  tax_year            text,
  quarter             int,
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

-- ── 6. Add next_rent_due to tenancies if missing ─────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'tenancies' AND column_name = 'next_rent_due'
  ) THEN
    ALTER TABLE tenancies ADD COLUMN next_rent_due date;
  END IF;
END $$;

-- ── 7. Compliance score function ─────────────────────────────
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
  SELECT COUNT(*) INTO total_expected
  FROM properties WHERE landlord_id = p_landlord_id;

  IF total_expected = 0 THEN RETURN 100; END IF;

  SELECT COUNT(DISTINCT p.id) INTO total_valid
  FROM properties p
  WHERE p.landlord_id = p_landlord_id
    AND NOT EXISTS (
      SELECT 1 FROM certificates c
      WHERE c.property_id = p.id
        AND c.expiry_date < now()
        AND c.cert_type NOT ILIKE '%epc%'
    );

  score := ROUND((total_valid::numeric / total_expected::numeric) * 100, 1);
  RETURN score;
END;
$$;

-- ── 8. Log purge function ─────────────────────────────────────
CREATE OR REPLACE FUNCTION purge_old_email_logs()
RETURNS void LANGUAGE sql SECURITY DEFINER AS $$
  DELETE FROM email_log WHERE sent_at < now() - interval '18 months';
$$;

-- ── Verify ───────────────────────────────────────────────────
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'email_log'
ORDER BY ordinal_position;
