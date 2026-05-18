-- Session 19: User Reports Table
-- Standalone table for bug reports and feature suggestions.
-- Replaces reliance on the legacy `feedback` table.
-- Run in Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS user_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  type        TEXT NOT NULL CHECK (type IN ('bug', 'feature')),
  title       TEXT NOT NULL,
  description TEXT NOT NULL,
  urgency     TEXT NOT NULL DEFAULT 'medium' CHECK (urgency IN ('low', 'medium', 'high', 'critical')),
  files       TEXT[] DEFAULT '{}',
  status      TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'reviewed', 'in_progress', 'completed', 'declined')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE user_reports ENABLE ROW LEVEL SECURITY;

-- Users can view their own reports
CREATE POLICY "Users can view own reports" ON user_reports
  FOR SELECT USING (user_id = auth.uid());

-- Authenticated users can insert reports
CREATE POLICY "Users can insert reports" ON user_reports
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Service role can manage all reports
CREATE POLICY "Service role can manage reports" ON user_reports
  FOR ALL USING (auth.role() = 'service_role');

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_user_reports_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_user_reports_updated_at ON user_reports;
CREATE TRIGGER trg_user_reports_updated_at
  BEFORE UPDATE ON user_reports
  FOR EACH ROW
  EXECUTE FUNCTION update_user_reports_updated_at();

COMMENT ON TABLE user_reports IS 'User-submitted bug reports and feature suggestions';
COMMENT ON COLUMN user_reports.type IS 'bug or feature';
COMMENT ON COLUMN user_reports.urgency IS 'low, medium, high, critical';
COMMENT ON COLUMN user_reports.status IS 'open, reviewed, in_progress, completed, declined';
COMMENT ON COLUMN user_reports.files IS 'Array of file paths in Storage bucket documents/feedback/{userId}/...';
