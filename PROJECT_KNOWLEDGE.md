# PROJECT_KNOWLEDGE.md

## NexLet — UK Landlord Compliance Platform

> **Purpose:** Single source of truth for any developer or AI coding agent working on this project.
> Read this file first before making any changes. Update it when architectural decisions are made.
> Rebrand: RentSafeAI → NexLet (May 2026). Repo/directory name unchanged (`rentsafeai`).

---

## 1. Project Overview

**NexLet** is a UK landlord SaaS platform helping private landlords stay legally compliant, manage properties efficiently, and prepare for Making Tax Digital (MTD) obligations. Built ground-up for the **Renters' Rights Act 2025** (RRA 2025).

| Detail | Value |
|---|---|
| **Project name** | NexLet (formerly RentSafeAI) |
| **Live URL** | https://nexlet.co.uk |
| **GitHub** | https://github.com/sddhawan79-lang/rentsafeai |
| **Local path** | `C:\Dev\rentsafeai` |
| **Target market** | UK private landlords (1-10 properties typical; unlimited for Portfolio plan) |
| **Founder** | Saurabh Dhawan ("Saby") |

### Core Value Propositions

- **Compliance tracking** — Gas Safety, EICR, EPC certificates with RAG (Red/Amber/Green) status, 17+ regulatory checks
- **Maintenance management** — Kanban board with Awaab's Law enforcement (damp/mould 14-day deadlines)
- **Legal document generation** — Section 8 notices (38 grounds), Section 13 rent increase, AST, Written Statement, RRA Info Sheet, inventory reports, plus 20 AI-generated templates
- **Making Tax Digital (MTD)** — Quarterly submission tracking, Section 24 calculator, HMRC phase timeline
- **Tenant portal** — Token-based no-login access for tenants to report issues, view jobs, download certificates, e-sign documents
- **Email alerts** — 8 automated alert types delivered via Resend, deduplicated via `email_log`
- **AI assistant** — Claude-powered chat for landlord questions + AI maintenance priority classification + document scanning

### Regulatory Context

- **Renters' Rights Act 2025 (RRA 2025)** — All Section 8 grounds (38 grounds, Housing Act 1988 Schedule 2 as amended 1 May 2026). Enforcement begins 31 May 2026.
- **Awaab's Law** — Damp/mould issues open 14+ days trigger critical alerts. Keywords: `damp`, `mould`, `mold`, `condensation`, `leak`, `water ingress`, `black mould`
- **MTD for Income Tax (ITSA)** — Phase 1: Apr 2026 (>£50k), Phase 2: Apr 2027 (>£30k), Phase 3: Apr 2028 (>£20k)
- **Section 24** — Mortgage interest restriction; tax calculator built into MTD module
- **Section 21** — Abolished by RRA 2025 (Section 8 is now the sole eviction route)

---

## 2. Tech Stack

### Frontend

| Layer | Technology |
|---|---|
| **Language** | Vanilla HTML5 / CSS3 / JavaScript (ES6+) — no framework, no bundler, no build step |
| **CSS approach** | `<style>` blocks inline in each HTML file; CSS custom properties (`:root` variables); `mtd.html` also uses Tailwind CSS via CDN |
| **Fonts** | Google Fonts: `DM Serif Display` (headings), `DM Sans` (body); `index.html` uses `Playfair Display` for headings |
| **Icons** | Inline SVGs only — no icon library |
| **Supabase client** | `@supabase/supabase-js` v2.39.3 via jsDelivr CDN |
| **No package.json** | No `node_modules/`, no `src/`, no bundler — static files served directly |

### Third-Party Services (CDN-loaded)

| Service | Purpose | Config |
|---|---|---|
| **signature_pad** v4.1.7 | E-signature canvas on tenant/esign portal | CDN in `tenant.html`, `esign.html` |
| **jsPDF** v2.5.1 | PDF generation (A4 multi-page) | CDN in `tenant.html`, `landlord.html`, `esign.html` |
| **Crisp** (ID: `6a5c5215-3c14-4afa-94a4-f1f8b05e2f62`) | Live chat widget | `index.html`, `login.html`, `tenant.html`, `mtd.html` |
| **Formspree** (`xdapbzqv`) | Waitlist + contact form email capture | `index.html` |
| **Tailwind CSS** (CDN) | Used only in `mtd.html` | `script src="https://cdn.tailwindcss.com"` |

### Backend / Infrastructure

| Service | Purpose | Notes |
|---|---|---|
| **Supabase** | PostgreSQL database, Auth, Edge Functions (Deno), Storage, RLS | Project ref: `mahtcfukgzbonwibtsxz` |
| **Resend** | Transactional email (`documents@nexlet.co.uk`) | Edge Function secret `RESEND_API_KEY` |
| **Stripe** | Subscription billing (Checkout-hosted) | Edge Function secrets; test mode for now |
| **Anthropic Claude** (`claude-sonnet-4-5`) | AI chat, maintenance classification, document scanning | Via `ai-proxy` edge function |
| **GitHub Pages** | Static hosting with custom domain (`nexlet.co.uk`) | `CNAME` file; no CI/CD |
| **pg_cron + pg_net** | Scheduled jobs within Supabase PostgreSQL | Alert emails, log purge |

### Supabase URLs & Keys

```
SUPABASE_URL      = 'https://mahtcfukgzbonwibtsxz.supabase.co'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIs...'  // Safe to expose (RLS enforced)
Dashboard URL      = https://supabase.com/dashboard/project/mahtcfukgzbonwibtsxz
```

---

## 3. Repository & File Structure

```
rentsafeai/                          (repo root — all files served by GitHub Pages)
├── index.html                       Marketing landing page (slate teal/amber rebrand)
├── login.html                       Auth: email+password, Google OAuth, reset password
├── signup.html                      Sign-up with password strength meter
├── profile.html                     Account & Billing settings (Stripe subscriptions)
├── landlord.html                    Main landlord SPA (~10,500+ lines) — entire dashboard
├── tenant.html                      Tenant portal (~940 lines) — token-based access
├── esign.html                       Standalone e-sign page — landlord+tenant signing
├── mtd.html                         Making Tax Digital standalone module (~1,200 lines, Tailwind)
├── app-mockup.html                  Static dashboard preview used in landing page iframe
│
├── privacy.html                     Privacy policy
├── terms.html                       Terms of service
├── complaints.html                  Complaints policy
├── ai-disclaimer.html               AI liability disclaimer
├── cookies.html                     Cookie policy
├── dpa.html                         GDPR / Data Protection Act page
├── nav_snippet.html                 Dev snippet: MTD nav item code (copy-paste reference)
│
├── og-image.png                     OpenGraph social share image (1200×630)
├── CNAME                            GitHub Pages custom domain: nexlet.co.uk
├── .gitignore                       Ignores landlord_new.html
│
├── js/
│   ├── lib/
│   │   ├── supabase-client.js       Single Supabase client singleton (window.RSA.sb)
│   │   ├── auth.js                  Session check, redirect, onAuthStateChange helpers
│   │   ├── ui.js                    Shared DOM helpers: showError, showSuccess, setLoading, field marks
│   │   ├── validation.js            Input validators: email, password strength rules (5 rules)
│   │   └── cookies.js               Cookie consent banner (localStorage 'rsa_cookies')
│   ├── signup.js                    Sign-up page logic (IIFE module) ✓
│   ├── profile.js                   Account & Billing / Stripe checkout logic (IIFE) ✓
│   └── esign-content.js             Standalone e-sign signing flow (IIFE) ✓
│
├── supabase/
│   ├── .temp/
│   │   └── linked-project.json      Local Supabase project link
│   └── functions/
│       ├── ai-proxy/
│       │   └── index.ts             Claude AI proxy + email sending via Resend
│       └── email-alerts/
│           └── index.ts             8 automated alert types via Resend + pg_cron
│
├── email-alerts-index.ts            Source copy of email-alerts edge function
├── stripe-checkout-index.ts         Source copy of stripe-checkout edge function
├── stripe-webhook-index.ts          Source copy of stripe-webhook edge function
│
├── mtd_tables.sql                   SQL: MTD tables (mtd_expenses, mtd_quarter_status, mtd_settings)
├── sprint10_step1_db.sql            SQL: email_log, property_insurance, mtd_periods, functions
├── sprint10_step1_fix.sql           SQL: Sprint 10 patch/fix
├── sprint10_step2_cron.sql          SQL: pg_cron scheduled jobs
├── sprint13_db.sql                  SQL: user_profiles + stripe_subscriptions tables + RLS
├── session7_tenant_documents.sql    SQL: tenant_documents table + RLS
├── session10_multi_doc.sql          SQL: multi-doc KYC (drop unique index, add columns)
├── session10_tenants_columns.sql    SQL: 13 missing tenants columns (rtr, rent_day, scheme_ref, etc.)
├── session10_esign_requests.sql     SQL: esign_requests table + RLS
├── session11_feedback_table.sql     SQL: User feedback table
├── session13_inventory_reports.sql  SQL: inventory_reports table + RLS
├── session14_tenant_checklist.sql   SQL: compliance_checklist JSONB column on tenants
├── session14_trial_fields.sql       SQL: trial fields (trial_started_at, expires, plan)
├── session14_rent_payments.sql      SQL: rent_payments table + RLS
├── session_archive.sql              SQL: archived tenant + account soft-delete
├── sprint10_fix_cron_key.sql        SQL: re-creates cron jobs with real service role key
│
├── SPRINT10_DEPLOY.md               Sprint 10 deployment guide
├── PROJECT_KNOWLEDGE.md             THIS FILE
├── fix.b64                          Binary patch (base64 encoded)
├── fix.patch                        Git patch file
└── fix.py                           Python fix script
```

### HTML File Responsibilities

| File | Purpose | Auth | Key details |
|---|---|---|---|
| `index.html` | Marketing landing page | None | Teal/amber rebrand palette, countdown banner, pricing tiers, Crisp chat |
| `login.html` | Login / signup / Google OAuth / password reset | None | Two-panel layout (navy left, white right) |
| `signup.html` | Account creation with 5-rule password strength meter | None | Real-time validation, duplicate email detection |
| `profile.html` | Account details, personal info, Stripe subscription | Yes (JWT) | Sticky top bar, no sidebar, Stripe Checkout, account closure |
| `landlord.html` | Full landlord SPA — all dashboard modules | Yes (JWT) | ~10,500 lines, inline JS (migration to js/landlord.js planned) |
| `tenant.html` | Tenant portal — token-based, no Supabase auth | Token | Reports, rent, documents, e-sign redirect |
| `esign.html` | Standalone e-sign signing page | Token | ECA 2000 consent, signature_pad, jsPDF, IP capture |
| `mtd.html` | MTD tax module — standalone | Yes (JWT) | Tailwind CSS, dark theme, MTD phase scope checker |

---

## 4. Database Schema

All tables are PostgreSQL via Supabase. All have Row Level Security (RLS) enabled. No local migration tooling — all schema changes run manually in Supabase SQL Editor.

### Core Tables

#### `properties`
Property listing per landlord. Columns: `id` (uuid PK), `user_id` (uuid FK → auth.users), `address`, `city`, `postcode`, `type`, `beds`, `bathrooms`, `rent`, `score`, `purchase_price`, `current_value`, `ownership_type` (Personal/Limited Co), `mortgage_outstanding`, `licence_type` (HMO/selective), `epc_rating` (A-G).

#### `tenants`
Tenancy records. Columns: `id` (uuid PK), `user_id` (FK), `prop_id` (FK → properties), `name`, `email`, `phone`, `type` (APT/AST/Company let), `start_date`, `end_date`, `rent`, `rent_day`, `deposit`, `deposit_scheme` (TDS/DPS/MyDeposits), `scheme_ref`, `rtr_check_date`, `rtr_expiry`, `rtr_checked_by`, `rtr_doc_type`, `rtr_ref`, `rtr_skipped`, `addr_proof_1`, `addr_proof_2`, `is_lead`, `status` (active/revoked/Ended), `invite_token` (unique token for tenant portal), `invite_used`, `landlord_email`, `archived`, `archived_at`, `end_reason`, `compliance_checklist` (JSONB).

#### `certificates`
Certificate records per property. Columns: `id` (uuid PK), `prop_id` (FK), `cert_type`, `status`, `expiry_date`, `has_file`, `cert_ref`, `amount`.

#### `maintenance`
Maintenance/repair jobs. Columns: `id` (uuid PK), `prop_id` (FK), `user_id` (FK), `title`, `description`, `cat`, `priority` (low/medium/high/critical), `status` (Kanban stage), `stage`, `issue_date`, `awaab` (boolean).

#### `tenant_maintenance`
Maintenance submitted via tenant portal (token-based, no auth). Same structure as maintenance but includes `tenancy_ref` (invite token), `ai_priority` (Claude-classified), `locked`, `photos` (text[] Storage paths), `completion_notes`, `completion_contractor`, `resolved_at`.

#### `rent_payments`
Rent payment tracking. Columns: `id` (uuid PK), `prop_id`, `user_id`, `tenant_id`, `amount`, `due_date`, `paid_date`, `status` (paid/overdue/pending), `month`, `notes`.

#### `email_log`
Deduplication for all outgoing alerts. Columns: `id` (uuid PK), `landlord_id` (FK), `alert_type` (one of 8 types), `reference_key` (deterministic dedup key), `recipient_email`, `sent_at`, `metadata` (jsonb). Unique index: `(landlord_id, alert_type, reference_key)`.

#### `user_profiles` (Sprint 13)
One row per user (PK matches `auth.users.id`). Columns: `id` (uuid PK), `full_name`, `phone`, `company_name`, `address`, `utr_number`, `trial_started_at`, `trial_expires_at`, `plan`, `plan_activated_at`, `deleted_at`, `created_at`, `updated_at`. RLS: users can SELECT/INSERT/UPDATE own row.

#### `stripe_subscriptions` (Sprint 13)
One row per user (UNIQUE on `user_id`). Columns: `id` (uuid PK), `user_id` (FK UNIQUE), `stripe_customer_id`, `stripe_subscription_id`, `stripe_price_id`, `plan_name` (starter/landlord/portfolio), `status` (active/trialing/past_due/canceled/incomplete), `current_period_start`, `current_period_end`, `cancel_at_period_end`, `created_at`, `updated_at`. RLS: SELECT only (own row); INSERT/UPDATE service-role only.

### Supporting Tables

| Table | Purpose |
|---|---|
| `insurance` | Per-property insurance policies (provider, expiry) |
| `property_insurance` | Per-property insurance with expiry_date (Sprint 10) |
| `contractors` | Contractor directory (name, trade, phone, email) |
| `job_assignments` | Links maintenance jobs to contractors |
| `custom_templates` | User-defined document templates |
| `audit_log` | Action audit trail (action, table_name, record_id, details, timestamp) |
| `checklist_progress` | Inspection checklist state per property |
| `meter_readings` | Gas/electric meter readings |
| `esign_requests` | E-signature requests with token for tenant portal |
| `tenant_documents` | Tenant KYC documents — passport, RTR, address proofs, references, guarantor. Multiple docs per slot (unique index removed). AI-scanned with Claude (`issuing_authority`, `doc_type_extracted`). Storage bucket: `tenant-documents`. |
| `inventory_reports` | AI-generated inventory reports persistence (Sprint 13) |

### MTD Tables (`mtd_tables.sql`)

| Table | Purpose |
|---|---|
| `mtd_periods` | HMRC quarterly periods: period_start, period_end, submission_deadline, status, tax_year, quarter |
| `mtd_expenses` | HMRC-categorised expenses: user_id, property_id, amount, category, expense_date, quarter, tax_year, is_section24 |
| `mtd_quarter_status` | Submission status per user/year/quarter: not_started → in_progress → ready → submitted |
| `mtd_settings` | User MTD profile: gross_income, tax_rate, is_limited_co, use_cash_basis |

### PostgreSQL Functions

| Function | Returns | Purpose |
|---|---|---|
| `get_compliance_score(p_landlord_id uuid)` | numeric 0-100 | Ratio of properties with no expired certs (excludes EPC), rounded to 1 decimal |
| `purge_old_email_logs()` | void | Deletes email_log entries older than 18 months |

---

## 5. Edge Functions (Supabase / Deno)

All edge functions run on Deno runtime. Deploy via: `npx supabase functions deploy <name> --project-ref mahtcfukgzbonwibtsxz`

### `ai-proxy` — Canonical AI function (Session 6)
- **Source:** `supabase/functions/ai-proxy/index.ts` (exists in repo)
- **URL:** `https://mahtcfukgzbonwibtsxz.supabase.co/functions/v1/ai-proxy`
- **Deploy:** `npx supabase functions deploy ai-proxy --project-ref mahtcfukgzbonwibtsxz --no-verify-jwt`
- **Secrets:** `ANTHROPIC_API_KEY`, `RESEND_API_KEY`
- **Handles:** Claude AI requests (proxies to `api.anthropic.com/v1/messages`) + email via Resend (`body.type === 'send_email'`)
- **Model:** `claude-sonnet-4-5` (default)
- **Replaces `super-processor`** — do NOT use super-processor in any new code

### `email-alerts` (Sprint 10)
- **Source:** `supabase/functions/email-alerts/index.ts`
- **Auth:** Service role key in `Authorization` header (sent by pg_cron)
- **Trigger:** HTTP POST with `{"type": "daily"}` or `{"type": "weekly_summary"}`
- **8 alert types:** cert_expiry, rent_overdue, maintenance_overdue, awaab_law, mtd_deadline, insurance_expiry, compliance_score, weekly_summary
- **Dedup:** `email_log` table unique index `(landlord_id, alert_type, reference_key)`

### `stripe-checkout` (Sprint 13)
- **Source:** `stripe-checkout-index.ts` → copy to `supabase/functions/stripe-checkout/index.ts`
- **Auth:** Requires valid Supabase JWT (standard verify-jwt)
- **Trigger:** HTTP POST from `js/profile.js` via `supabase.functions.invoke('stripe-checkout', { body: { plan } })`
- **Response:** `{ url: 'https://checkout.stripe.com/pay/...' }`
- **Secrets:** `STRIPE_SECRET_KEY`, `STRIPE_PRICE_STARTER`, `STRIPE_PRICE_LANDLORD`, `STRIPE_PRICE_PORTFOLIO`

### `stripe-webhook` (Sprint 13)
- **Source:** `stripe-webhook-index.ts` → copy to `supabase/functions/stripe-webhook/index.ts`
- **Auth:** No JWT — Stripe calls directly. Deploy with `--no-verify-jwt`.
- **Security:** Stripe-Signature verified via `stripe.webhooks.constructEventAsync()`
- **Events:** `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`
- **Webhook URL:** `https://mahtcfukgzbonwibtsxz.supabase.co/functions/v1/stripe-webhook`

### `super-processor` (DEPRECATED)
Do NOT use. All references replaced with `ai-proxy` in Session 6.

---

## 6. Email Alert System

### Alert Types & Triggers

| Alert | Trigger Condition | Dedup Key | Re-fires? |
|---|---|---|---|
| `cert_expiry` | 60 / 30 / 14 / 7 days before expiry_date | `cert_{id}_{days}d` | Never (once per window) |
| `rent_overdue` | 1 day after next_rent_due | `rent_overdue_{id}_{date}` | Never (once per due date) |
| `maintenance_overdue` | 7+ days with no update | `maint_overdue_{id}_{week}` | Weekly while unresolved |
| `awaab_law` | 14+ days open + damp/mould keyword | `awaab_{id}_{isoWeek}` | Weekly while unresolved |
| `mtd_deadline` | 30 / 14 / 7 days before submission deadline | `mtd_{id}_{days}d` | Never (once per window) |
| `insurance_expiry` | 60 / 30 days before policy expiry | `insurance_{id}_{days}d` | Never (once per window) |
| `compliance_score` | Score drops below 70% | `compliance_{landlord}_{date}` | Daily while below threshold |
| `weekly_summary` | Every Monday | `summary_{landlord}_{week}` | Weekly (new key each week) |

### Cron Schedule (pg_cron)

| Job | Schedule | UTC | Action |
|---|---|---|---|
| `rentsafeai-daily-alerts` | `0 9 * * *` | 09:00 daily | POST daily alerts |
| `rentsafeai-weekly-summary` | `0 8 * * 1` | 08:00 Mon | POST weekly summary |
| `rentsafeai-monthly-purge` | `0 2 1 * *` | 02:00 1st | Purge old email_log entries |

### Awaab's Law Keywords
`damp`, `mould`, `mold`, `condensation`, `leak`, `water ingress`, `black mould`

---

## 7. Key Business Logic

### Compliance Scoring
- **Client-side** (`calcRAG()` in `landlord.html`): Required certs: Gas Safety, EICR, Electrical, EPC, Energy, Deposit. Deductions: -15 expired, -10 missing, -5 due, -10 missing critical. RAG: Green ≥80%, Amber ≥50%, Red <50%.
- **Server-side** (`get_compliance_score()`): Ratio of properties with no expired certs (excludes EPC), returns 0-100.

### Section 8 Notice Generator
- 38 grounds (RRA 2025, Housing Act 1988 Schedule 2 as amended 1 May 2026)
- Mandatory vs Discretionary classification, 5-step wizard, auto-calculated notice periods
- 3-checkbox liability disclaimer with audit logging
- PDF download via jsPDF with A4 multi-page
- GOV.UK Form 3A direct download link on review screen (auto-fill pending)

### Subscription Plan Gating
Plans resolved from `stripe_subscriptions.plan_name`, falling back to `'portfolio'` for grandfathered users.

| Plan | Properties | Features |
|---|---|---|
| **Starter** | 2 | Core: compliance, documents, e-sign, maintenance, tenant portal, AI chat, calendar, deposit alerts, contractor book |
| **Landlord** | 10 | Starter + bulk gen, portfolio health, audit log, rent tracking, insurance |
| **Portfolio** | Unlimited | All features: MTD Tax, AI Inventory Report, Custom Templates |

Enforcement: `nav()` intercepts restricted routes with `upgradePrompt()`. `moAddProp()` blocks at limit. `canAccess()` checks per-feature.

### 30-Day Free Trial
- Trial state resolved inline at startup via `_trialState` cache
- Full portfolio access during trial (`effectivePlan()` returns `'portfolio'`)
- Expiry: non-dismissable popup, amber banner on every page, sidebar indicator
- `nav()` blocks all non-dashboard pages for expired trial users
- Trial emails: day 25, 28, 30, expired — sent via `ai-proxy`

### Tenant Portal Token System
- `invite_token` on `tenants` record → URL `?token=xxx`
- No Supabase Auth required — access via token lookup + RLS
- Revocation: set `tenants.status = 'revoked'` → "Access revoked"
- E-sign flow: `?esign=xxx` → looks up `esign_requests` table → redirects to `esign.html`

### Data Loading Pattern (`landlord.html`)
`loadData()` fires 13 parallel Supabase queries on startup: `properties`, `tenants`, `certificates`, `maintenance`, `rent_payments`, `insurance`, `email_log`, `custom_templates`, `contractors`, `job_assignments`, `tenant_documents`, `user_profiles`, `stripe_subscriptions`. Result stored in `D` global object.

### AI Chat Assistant (`sendChat()` in `landlord.html`)
- Claude via `ai-proxy` edge function
- `SYSTEM_PROMPT` constant provides full platform knowledge (sidebar paths, features, workflows, pricing) + UK law expertise (RRA 2025, Section 8/13, Awaab's Law, deposits, HMO, MTD)
- Rules: give sidebar navigation paths, state "not legal advice", max_tokens=800
- Chat history in-memory only (`D.chat[]`) — clears on refresh

### Legal Document Disclaimer Gate
3-checkbox pre-generation consent for 4 legal document types (Section 8, Section 13, Notice to Quit, Written Statement). Captures user selections, requires: AI draft acknowledgment, personal liability, independent legal advice. On accept: audit log entry + generation.

---

## 8. Pricing & Plans

Two-tier pricing (founding / standard), toggled on `index.html`.

| Plan | Founding (monthly) | Founding (annual) | Standard (monthly) | Standard (annual) | Props |
|---|---|---|---|---|---|
| **Starter** | £4.99/mo | £3.99/mo | £7.99/mo | £6.66/mo | ≤3 |
| **Landlord** | £9.99/mo | £8.33/mo | £14.99/mo | £12.49/mo | ≤10 |
| **Portfolio** | £23.99/mo | £19.99/mo | £39.99/mo | £33.32/mo | Unlimited |

Annual: 2 months free (pay 10, get 12). Founding prices lock for life for first 100 users.

---

## 9. How to Build, Run, Test, Lint

### There is no build step
No `package.json`, no `node_modules`, no bundler. All files are static HTML/CSS/JS served as-is.

### Running locally
Open any `.html` file directly in a browser. No local server required (except for CORS — some features need Supabase backend).

### Deployment
```powershell
# Static frontend (GitHub Pages) — push to deploy
git push origin main
```

### Edge Function Deployment
```powershell
# One-time login
npx supabase login

# Deploy each function (run separately — PowerShell does NOT support &&)
npx supabase functions deploy email-alerts --project-ref mahtcfukgzbonwibtsxz
npx supabase functions deploy ai-proxy --project-ref mahtcfukgzbonwibtsxz --no-verify-jwt

# For stripe functions, copy root .ts files to subfolders first
Copy-Item stripe-checkout-index.ts supabase\functions\stripe-checkout\index.ts -Force
npx supabase functions deploy stripe-checkout --project-ref mahtcfukgzbonwibtsxz

Copy-Item stripe-webhook-index.ts supabase\functions\stripe-webhook\index.ts -Force
npx supabase functions deploy stripe-webhook --project-ref mahtcfukgzbonwibtsxz --no-verify-jwt
```

### Database Migrations
All SQL files run manually in **Supabase Dashboard → SQL Editor**. No automated migration tool. See the SQL files section above for the correct order.

### Testing
No automated test suite exists. Manual testing only:
- Edge function logs: Supabase → Edge Functions → click function → Logs tab
- Email log queries: `SELECT * FROM email_log ORDER BY sent_at DESC LIMIT 20;`
- Cron job history: query `cron.job_run_details` (see monitoring queries in `SPRINT10_DEPLOY.md`)

### Linting / Formatting
No linter or formatter configured. No `eslint`, `prettier`, or type checking.

---

## 10. Coding Conventions

### JavaScript File Structure
- Each HTML page has a corresponding JS file in `js/` (pages being migrated from inline JS)
- Shared utilities in `js/lib/` — never duplicated
- **Already migrated:** `profile.js`, `signup.js`, `esign-content.js`
- **Planned:** `landlord.js`, `tenant.js`, `mtd.js`, `login.js`, `index.js`

### Module Pattern (IIFE)
All page-level JS wrapped in IIFE to avoid polluting global scope:
```javascript
(function () {
  'use strict';
  // private state and helpers (prefixed with _)
  // public API exposed via window.xxx only if needed by HTML onclick handlers
  // wire events in DOMContentLoaded, NOT inline onclick=""
})();
```

### Shared Libraries Pattern
Libraries attach to `window.RSA` namespace in dependency order:
- `window.RSA.sb` — Supabase client singleton
- `window.RSA.Auth` — Auth helpers (requireSession, redirectIfLoggedIn, etc.)
- `window.RSA.UI` — DOM helpers (showError, showSuccess, setLoading, field marks)
- `window.RSA.Validation` — Input validators (password rules, email check)
- `window.RSA.Cookies` — Cookie consent banner logic

### Naming Conventions
| Thing | Convention | Example |
|---|---|---|
| JS files | `kebab-case.js` | `supabase-client.js` |
| Functions | `camelCase` | `loadProperties()` |
| Private (IIFE) | `_camelCase` | `_calcRAG()` |
| Constants | `UPPER_SNAKE_CASE` | `SUPABASE_URL` |
| DOM IDs | `kebab-case` | `error-msg`, `signup-btn` |
| CSS classes | `kebab-case` | `pw-strength`, `btn-login` |
| DB column refs in JS | Match DB exactly | `prop_id`, `cert_type` |

### CSS Rules
- All CSS in `<style>` blocks within HTML files — no separate `.css` files
- CSS variables in `:root` at top of each `<style>` block
- Canonical tokens (from `login.html`, `tenant.html`, `esign.html`):
```css
:root {
  --navy:      #0B1E3D;  --navy-mid:  #132847;
  --green:     #00C896;  --green-dark: #009970;
  --white:     #fff;     --off:       #F6F8FB;
  --border:    #E4EAF1;  --txt:       #1A2B45;
  --muted:     #7A8FA6;  --red:       #E53E3E;
  --amber:     #D97706;  --blue:      #3B6FE8;
  --font:      'DM Sans', system-ui, sans-serif;
  --disp:      'DM Serif Display', Georgia, serif;
}
```
- `index.html` uses teal/amber palette (rebranded): `--teal`, `--amber`, `--slate`, `--bg #F8F6F1`
- `mtd.html` uses Tailwind CSS (CDN) with custom theme

### Error Handling
- Every `async` function must have `try/catch` or check Supabase `{ data, error }`
- Never swallow errors silently — at minimum `console.error()` with context
- User-facing errors via shared `showError(el, msg)` in `js/lib/ui.js`
- Loading states: disable button, show spinner, re-enable in `finally`

### Debugging
- Prefix console calls with `[filename:functionName]`
- Use `_logError()` (wrapped behind `RENTSAFE_DEBUG` flag) in `landlord.html`
- Never commit `console.log` debug statements

### No Inline Scripts Policy
- No `<script>` blocks inside HTML (except Crisp snippet, Supabase CDN, Tailwind CDN)
- No `onclick="..."` attributes — wire events in JS via `DOMContentLoaded`

### Incremental Migration Path
When modifying monolithic files (`landlord.html`, `tenant.html`, `mtd.html`):
1. Extract only the functions being modified into the appropriate `js/` file
2. Replace inline code with `<script src="js/...">` reference
3. Do NOT attempt full extraction in one go
4. Priority order: `login.js` → `signup.js` → `index.js` → `tenant.js` → `mtd.js` → `landlord.js`

---

## 11. Known Issues & Technical Debt

| # | Issue | Area | Status |
|---|---|---|---|
| 1 | HTTPS "Not secure" on nexlet.co.uk | GitHub Pages SSL | Pending |
| 2 | Resend SPF/DKIM records not set — emails unreliable | DNS/Email | Pending |
| 3 | Form 3A PDF not auto-generated (download link added) | Section 8 | Partial — auto-fill pending |
| 4 | `tenant-documents` Storage bucket not created | Storage | Pending |
| 5 | No tenant data input validation | Tenant portal | Tech debt |
| 6 | No offline/error recovery states | General | Tech debt |
| 7 | MX record missing for nexlet.co.uk | DNS/Email | Post-launch |
| 8 | `inventory_reports` table SQL not yet run | Database | Pending |
| 9 | Trial fields on `user_profiles` not yet column-migrated | Database | In-memory fallback only |
| 10 | Stripe not yet configured (test mode setup pending) | Billing | Setup checklist in Section 14 |

---

## 12. Feature Change Log

See the changelog at the end of the original `PROJECT_KNOWLEDGE.md` for the complete history. Key sessions:

- **Session 6** — AI fix: created `ai-proxy` edge function, replaced `super-processor`
- **Session 7** — QA, bug fixes (parseInt UUID fix, 22 locations), Section 8 grounds update
- **Session 8** — Landlord name from profile, Complaints policy, Legal disclaimer gate, footer fixes
- **Session 9** — Rent save fix, Property tabs fix, PDF jsPDF rewrite, AI chat upgrade, Inventory fix, Plan gating
- **Session 10** — E-Sign standalone page, Multi-doc KYC, Tenant wizard restructure, Awaab's Law keywords
- **Session 11** — Account closure, End tenancy/archive, Email alerts deploy, Dashboard UX, Sidebar additions
- **Session 13** — Section 8 grounds (31→38), Code quality fixes (console.error wrapping, alert removal), Inventory full-page + send-to-tenant
- **Session 14** — Tenant fast-add modal, RAG Compliance Checklist, 30-day free trial, Landing page rebrand (teal/amber), RentSafeAI → NexLet rebrand
- **Sprint 10** — Email alert system (8 alerts, pg_cron, email_log dedup)
- **Sprint 11** — `signup.html`, Code standards codified in this document
- **Sprint 13** — `profile.html` + Stripe subscription billing (checkout + webhook)

---

## 13. Development Environment

### Prerequisites
- Git (for pushing to GitHub)
- Node.js (for `npx supabase` CLI commands)
- Supabase CLI (`npx supabase login`)
- A text editor (VS Code recommended)
- A web browser (Chrome/Edge for DevTools)

### Working with the Supabase CLI
```powershell
# Check current login
npx supabase projects list

# Deploy a function
npx supabase functions deploy <name> --project-ref mahtcfukgzbonwibtsxz

# Deploy without JWT verification (for webhooks, AI proxy)
npx supabase functions deploy <name> --project-ref mahtcfukgzbonwibtsxz --no-verify-jwt
```

### PowerShell Notes
- `&&` does NOT work in PowerShell for chaining commands — run each command separately
- Use `Copy-Item source dest -Force` instead of `cp`
- File paths with spaces must be quoted

### Stripe Test Cards
| Card number | Scenario |
|---|---|
| `4242 4242 4242 4242` | Successful payment |
| `4000 0025 0000 3155` | 3D Secure authentication required |
| `4000 0000 0000 9995` | Card declined |

---

## 14. Stripe Integration (pending setup)

### Flow
1. User clicks "Subscribe" on `profile.html` → `js/profile.js` invokes `stripe-checkout` edge function
2. Edge function creates Stripe Checkout Session → returns URL
3. Browser redirects to Stripe's hosted payment page
4. On completion: Stripe redirects to `profile.html?success=true`
5. In background: Stripe POSTs to `stripe-webhook` → `stripe_subscriptions` table updated

### Setup Steps
1. Stripe Dashboard: Get Secret key (`sk_test_...`), create 3 Products with Recurring prices
2. Supabase Dashboard: Add edge function secrets (`STRIPE_SECRET_KEY`, prices, `STRIPE_WEBHOOK_SECRET`)
3. Run `sprint13_db.sql` in Supabase SQL Editor
4. Deploy `stripe-checkout` and `stripe-webhook` edge functions
5. Register webhook endpoint in Stripe Dashboard
6. Test with Stripe test cards in test mode
