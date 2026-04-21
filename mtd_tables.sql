-- ─────────────────────────────────────────────
-- MTD TABLES — Run in Supabase SQL Editor
-- ─────────────────────────────────────────────

-- 1. MTD Expenses (HMRC-categorised)
CREATE TABLE IF NOT EXISTS mtd_expenses (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  property_id     UUID REFERENCES properties(id) ON DELETE SET NULL,
  amount          DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  category        TEXT NOT NULL,
  description     TEXT,
  expense_date    DATE NOT NULL,
  quarter         INTEGER NOT NULL CHECK (quarter IN (1,2,3,4)),
  tax_year        TEXT NOT NULL,   -- e.g. '2026-27'
  is_section24    BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 2. MTD Quarter Submission Status
CREATE TABLE IF NOT EXISTS mtd_quarter_status (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tax_year     TEXT NOT NULL,
  quarter      INTEGER NOT NULL CHECK (quarter IN (1,2,3,4)),
  status       TEXT DEFAULT 'not_started'
               CHECK (status IN ('not_started','in_progress','ready','submitted')),
  submitted_at TIMESTAMPTZ,
  notes        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, tax_year, quarter)
);

-- 3. MTD User Settings (gross income for scope check, tax profile)
CREATE TABLE IF NOT EXISTS mtd_settings (
  id                UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id           UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  gross_income      DECIMAL(10,2),          -- previous year gross to determine scope
  tax_rate          TEXT DEFAULT 'basic'
                    CHECK (tax_rate IN ('basic','higher','additional')),
  is_limited_co     BOOLEAN DEFAULT FALSE,
  use_cash_basis    BOOLEAN DEFAULT TRUE,
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- Row Level Security
-- ─────────────────────────────────────────────
ALTER TABLE mtd_expenses        ENABLE ROW LEVEL SECURITY;
ALTER TABLE mtd_quarter_status  ENABLE ROW LEVEL SECURITY;
ALTER TABLE mtd_settings        ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Own mtd_expenses"
  ON mtd_expenses FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Own mtd_quarter_status"
  ON mtd_quarter_status FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Own mtd_settings"
  ON mtd_settings FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────────
-- Indexes
-- ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_mtd_expenses_user_year_q
  ON mtd_expenses (user_id, tax_year, quarter);

CREATE INDEX IF NOT EXISTS idx_mtd_expenses_property
  ON mtd_expenses (property_id);

CREATE INDEX IF NOT EXISTS idx_mtd_quarter_status_user_year
  ON mtd_quarter_status (user_id, tax_year);
