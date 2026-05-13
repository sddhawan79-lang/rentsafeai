-- esign_requests table — for e-signature requests sent to tenants
-- Run this in Supabase SQL Editor BEFORE using the e-sign feature

CREATE TABLE IF NOT EXISTS esign_requests (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id     uuid REFERENCES properties(id) ON DELETE CASCADE,
  tenant_id       uuid REFERENCES tenants(id) ON DELETE CASCADE,
  document_type   text NOT NULL,
  document_html   text,
  document_pdf_url text,
  token           text UNIQUE NOT NULL,
  status          text DEFAULT 'pending',
  landlord_signature_pdf text,
  landlord_name   text,
  tenant_name     text,
  tenant_email    text,
  expires_at      timestamptz,
  signed_at       timestamptz,
  signed_pdf_url  text,
  ip_address      text,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

-- RLS: allow any authenticated user read/write (token-based access controls in app logic)
ALTER TABLE esign_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all authenticated access"
  ON esign_requests
  FOR ALL
  USING (auth.role() = 'authenticated');

-- Allow anon reads for tenant portal (token-based, no auth required)
CREATE POLICY "Allow anon read by token"
  ON esign_requests
  FOR SELECT
  USING (true);

CREATE POLICY "Allow anon update by token"
  ON esign_requests
  FOR UPDATE
  USING (true)
  WITH CHECK (true);
