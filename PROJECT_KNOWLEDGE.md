# PROJECT_KNOWLEDGE.md
## RentSafeAI — Agent Initialization Reference

> **Purpose:** Single point of truth for any agentic AI coding agent working on this project.
> Read this file first before making any changes. Update it as new features are added or
> architectural decisions are made.

---

## Table of Contents

1. [Project Overview & Business Purpose](#1-project-overview--business-purpose)
2. [Tech Stack](#2-tech-stack)
3. [Repository & File Structure](#3-repository--file-structure)
4. [Database Schema](#4-database-schema)
5. [Supabase Configuration](#5-supabase-configuration)
6. [Edge Functions](#6-edge-functions)
7. [Email Alert System (Sprint 10)](#7-email-alert-system-sprint-10)
8. [Deployment Configuration](#8-deployment-configuration)
9. [Key Business Logic](#9-key-business-logic)
10. [Known Issues & Technical Debt](#10-known-issues--technical-debt)
11. [Pricing & Plans](#11-pricing--plans)
12. [Feature Change Log](#12-feature-change-log)

---

## 1. Project Overview & Business Purpose

**RentSafeAI** is a UK landlord SaaS platform designed to help private landlords stay legally compliant, manage properties efficiently, and prepare for upcoming Making Tax Digital (MTD) obligations.

**Live URL:** https://rentsafeai.co.uk
**GitHub:** https://github.com/sddhawan79-lang/rentsafeai
**Target market:** UK private landlords (particularly those with 1–10 properties)

### Core Value Propositions
- **Compliance tracking** — Gas Safety, EICR, EPC certificates with RAG (Red/Amber/Green) status
- **Maintenance management** — Kanban board with Awaab's Law enforcement (damp/mould deadlines)
- **Legal document generation** — Section 8 notices (all 37 RRA 2025 grounds), S13 rent increase, AST, inspection reports
- **Making Tax Digital (MTD)** — Quarterly submission tracking, Section 24 calculator, HMRC phase timeline
- **Tenant portal** — Token-based no-login access for tenants to report issues, view jobs, download certificates, e-sign documents
- **Email alerts** — 8 automated alert types delivered via Resend, deduplicated via `email_log`
- **AI assistant** — Claude-powered chat for landlord questions + AI maintenance priority classification

### Regulatory Context
- **Renters Rights Act 2025 (RRA 2025)** — All 37 Section 8 grounds implemented
- **Awaab's Law** — Damp/mould issues open 14+ days trigger critical alerts
- **MTD for Income Tax (ITSA)** — Phase 1: Apr 2026 (>£50k), Phase 2: Apr 2027 (>£30k), Phase 3: Apr 2028 (>£20k)
- **Section 24 mortgage interest restriction** — Tax calculator built into MTD module

### Founder
Saurabh Dhawan (featured on landing page, `index.html` founder story section)

---

## 2. Tech Stack

### Frontend
| Layer | Technology |
|---|---|
| Language | Vanilla HTML5 / CSS3 / JavaScript (ES6+) — **no framework, no bundler** |
| CSS approach | Custom CSS variables, inline styles; `mtd.html` also uses Tailwind via CDN |
| Fonts | Google Fonts: `DM Serif Display` (headings), `DM Sans` (body) |
| Icons | Inline SVGs only — no icon library dependency |
| Supabase client | `@supabase/supabase-js` v2.39.3 via jsDelivr CDN |

### Backend / Third-Party Services
| Service | Purpose | Config location |
|---|---|---|
| **Supabase** | PostgreSQL database, Auth, Edge Functions, Storage, RLS | Hardcoded in HTML files |
| **Resend** | Transactional email (`documents@rentsafeai.co.uk`) | Edge Function secret `RESEND_API_KEY` |
| **Anthropic Claude** (`claude-sonnet-4-5`) | AI chat assistant + maintenance priority classification | `super-processor` edge function |
| **Formspree** (`xdapbzqv`) | Waitlist email capture on landing page | Inline in `index.html` |
| **Crisp** (ID: `6a5c5215-3c14-4afa-94a4-f1f8b05e2f62`) | Live chat widget | `index.html`, `login.html`, `tenant.html`, `mtd.html` |
| **signature_pad** v4.1.7 | E-signature canvas on tenant portal | CDN in `tenant.html` |
| **jsPDF** v2.5.1 | PDF generation in tenant portal | CDN in `tenant.html` |
| **GitHub Pages** | Static hosting with custom domain (`rentsafeai.co.uk`) | `CNAME` file |
| **Deno** | Runtime for all Supabase Edge Functions | Supabase managed |
| **pg_cron + pg_net** | Scheduled jobs within Supabase | `sprint10_step2_cron.sql` |

---

## 3. Repository & File Structure

> There is **no build step, no `node_modules`, no `package.json`, no `src/` folder**.
> All files live at the repository root and are served directly by GitHub Pages.

```
rentsafeai/
├── index.html                  Marketing landing page
├── login.html                  Auth page (login / signup / password reset)
├── landlord.html               Main SPA app (~3,973 lines) — entire landlord dashboard
├── tenant.html                 Tenant portal + e-sign flow (~1,200+ lines)
├── mtd.html                    Making Tax Digital standalone page (~1,500+ lines)
├── app-mockup.html             Static dashboard preview (iframe on landing page)
├── privacy.html                Privacy policy
├── Terms.html                  Terms of service
├── nav_snippet.html            Dev snippet: MTD nav item code (copy-paste reference)
├── og-image.png                OpenGraph social share image (1200×630)
├── CNAME                       GitHub Pages custom domain: rentsafeai.co.uk
├── email-alerts-index.ts       Supabase Edge Function source (Sprint 10)
├── mtd_tables.sql              SQL migration: MTD tables
├── sprint10_step1_db.sql       SQL migration: Sprint 10 DB setup
├── sprint10_step1_fix.sql      SQL migration: Sprint 10 patch/fix
├── sprint10_step2_cron.sql     SQL: pg_cron scheduled jobs
├── SPRINT10_DEPLOY.md          Sprint 10 deployment guide
├── PROJECT_KNOWLEDGE.md        THIS FILE — agent initialization reference
├── fix.b64                     Binary patch (base64 encoded)
└── fix.patch                   Git patch file
```

> **No `supabase/` folder.** Edge functions are deployed via `npx supabase functions deploy`
> and their source is kept as loose `.ts` files at the repo root.

### HTML File Responsibilities

| File | Purpose | Auth required |
|---|---|---|
| `index.html` | Marketing: hero, pricing, features, founder, FAQ | None |
| `login.html` | Supabase email+password + Google OAuth + password reset | None |
| `landlord.html` | Full landlord SPA — all dashboard modules | Yes — redirects to `login.html` |
| `tenant.html` | Tenant portal — token-based, no Supabase auth needed | Token in URL or localStorage |
| `mtd.html` | MTD tax module — standalone (Tailwind CSS) | Yes — uses Supabase session |

---

## 4. Database Schema

> All tables use PostgreSQL via Supabase. All have Row Level Security (RLS) enabled.
> No local migration tooling — all schema changes are run manually in Supabase SQL Editor.

### Core Tables

#### `properties`
| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `user_id` | uuid FK | Supabase auth user |
| `address`, `city`, `postcode`, `country` | text | |
| `type` | text | Property type |
| `beds`, `bathrooms` | int | |
| `rent` | numeric | Monthly rent (£) |
| `score` | numeric | Compliance score |
| `purchase_price`, `current_value` | numeric | Portfolio valuation |
| `ownership_type` | text | Personal / Limited Co |
| `mortgage_outstanding` | numeric | |
| `licence_type` | text | HMO, selective, etc. |
| `epc_rating` | text | A–G |

#### `tenants`
| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `user_id` | uuid FK | Landlord's Supabase user |
| `prop_id` | uuid FK | → properties |
| `name`, `email`, `phone` | text | |
| `start_date`, `end_date` | date | Tenancy period |
| `rent`, `deposit` | numeric | |
| `deposit_scheme` | text | TDS / DPS / MyDeposits |
| `status` | text | `active`, `revoked` |
| `invite_token` | text | **Unique token for tenant portal URL** |
| `landlord_email` | text | For portal email display |

#### `certificates`
| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `prop_id` | uuid FK | → properties |
| `type` | text | Certificate category (legacy column) |
| `cert_type` | text | Certificate category (canonical) |
| `status` | text | `valid`, `expired`, `due` |
| `expiry`, `expiry_date` | date | Both columns exist |
| `has_file` | boolean | Whether a file is in Storage |

#### `maintenance`
| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `prop_id` | uuid FK | |
| `user_id` | uuid FK | Landlord |
| `title`, `description` | text | |
| `cat` | text | Category |
| `priority` | text | low / medium / high / critical |
| `status` | text | Kanban stage |
| `stage` | text | |
| `issue_date` | date | |
| `awaab` | boolean | Awaab's Law flag |

#### `rent_payments`
| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `prop_id`, `user_id` | uuid FK | |
| `amount` | numeric | |
| `due_date`, `paid_date` | date | |
| `status` | text | `paid`, `overdue`, `pending` |

#### `tenant_maintenance`
Maintenance jobs submitted via the tenant portal (token-based, no auth).
| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `tenancy_ref` | text | Invite token used for lookup |
| `prop_id` | uuid FK | |
| `user_id` | uuid | Landlord user ID |
| `description` | text | |
| `category`, `priority` | text | Tenant-entered |
| `ai_priority` | text | Claude-classified priority |
| `status` | text | |
| `locked` | boolean | Prevents editing after submission |
| `submitted_at` | timestamptz | |
| `photos` | text[] | Supabase Storage paths |
| `completion_notes`, `completion_contractor` | text | |
| `resolved_at` | timestamptz | |

#### `email_log`
Deduplication table for all outgoing alerts.
| Column | Type | Notes |
|---|---|---|
| `id` | uuid PK | |
| `landlord_id` | uuid FK | |
| `alert_type` | text | One of 8 types |
| `reference_key` | text | Deterministic dedup key |
| `recipient_email` | text | |
| `sent_at` | timestamptz | |
| `metadata` | jsonb | Extra context |

**Unique index:** `(landlord_id, alert_type, reference_key)` — prevents duplicate sends.

#### Other Core Tables
| Table | Purpose |
|---|---|
| `insurance` | Per-property insurance policies (`provider`, `expiry`) |
| `property_insurance` | Per-property insurance with `expiry_date` (Sprint 10 addition) |
| `contractors` | Contractor directory (`name`, `trade`, `phone`, `email`) |
| `job_assignments` | Links maintenance jobs to contractors |
| `custom_templates` | User-defined document templates |
| `audit_log` | Action audit trail (`action`, `table_name`, `record_id`, `details`) |
| `checklist_progress` | Inspection checklist state per property |
| `meter_readings` | Gas/electric meter readings |
| `esign_requests` | E-signature requests with `token` for tenant portal |

### MTD Tables (from `mtd_tables.sql`)
| Table | Purpose |
|---|---|
| `mtd_periods` | HMRC quarterly periods: `period_start`, `period_end`, `submission_deadline`, `status`, `tax_year`, `quarter` |
| `mtd_expenses` | HMRC-categorised expenses: `user_id`, `property_id`, `amount`, `category`, `expense_date`, `quarter`, `tax_year`, `is_section24` |
| `mtd_quarter_status` | Submission status per user/year/quarter: `not_started` → `in_progress` → `ready` → `submitted` |
| `mtd_settings` | User MTD profile: `gross_income`, `tax_rate`, `is_limited_co`, `use_cash_basis` |

### PostgreSQL Functions
| Function | Signature | Returns | Purpose |
|---|---|---|---|
| `get_compliance_score` | `(p_landlord_id uuid)` | numeric 0–100 | `ROUND((properties_with_no_expired_certs / total_properties) * 100, 1)` — excludes EPC |
| `purge_old_email_logs` | `()` | void | Deletes `email_log` entries older than 18 months |

---

## 5. Supabase Configuration

**Project reference:** `mahtcfukgzbonwibtsxz`
**Supabase URL:** `https://mahtcfukgzbonwibtsxz.supabase.co`
**Dashboard:** https://supabase.com/dashboard/project/mahtcfukgzbonwibtsxz

### Hardcoded Credentials (in HTML files)
```javascript
// These appear in landlord.html, tenant.html, mtd.html, login.html
const SUPABASE_URL      = 'https://mahtcfukgzbonwibtsxz.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
// Anon key is safe to expose (Supabase RLS enforces data security)
```

### Auth Configuration
- Email/password login via `signInWithPassword`
- Google OAuth via `signInWithOAuth` (redirect to `landlord.html`)
- Password reset via `resetPasswordForEmail`
- Magic link support in `login.html` via `onAuthStateChange`
- All pages: call `supabase.auth.getSession()` on load, redirect to `login.html` if no session

### Storage
- Bucket: `certificates`
- Path pattern: `{prop_id}/{cert_id}`
- Access: Signed URL downloads used in tenant portal

### Edge Function Secrets (set in Supabase Dashboard → Project Settings → Edge Functions → Secrets)
| Secret | Purpose |
|---|---|
| `RESEND_API_KEY` | Transactional email via Resend |
| `SUPABASE_URL` | Auto-injected by Supabase runtime |
| `SUPABASE_SERVICE_ROLE_KEY` | Auto-injected by Supabase runtime |

---

## 6. Edge Functions

> **Important:** Edge functions use the **Deno** runtime. TypeScript syntax required.
> Deploy command: `npx supabase functions deploy <function-name> --project-ref mahtcfukgzbonwibtsxz`
> Run each command separately in PowerShell — `&&` is NOT supported.

### Deployed Functions

#### `email-alerts` (Sprint 10)
- **Source file:** `email-alerts-index.ts` (root) → must be placed at `supabase/functions/email-alerts/index.ts` for deploy
- **Auth:** Uses service role key in `Authorization` header (sent by pg_cron)
- **`--no-verify-jwt`:** NOT used — cron jobs authenticate with service role key
- **Trigger:** HTTP POST with `{"type": "daily"}` or `{"type": "weekly_summary"}`
- **Full details:** See [Section 7](#7-email-alert-system-sprint-10)

#### `super-processor` (pre-existing, not in repo)
- Handles: AI chat (Claude `claude-sonnet-4-5`), email sending via Resend
- Used by: `landlord.html` AI assistant, `tenant.html` AI priority classification
- **EDGE_URL:** `https://mahtcfukgzbonwibtsxz.supabase.co/functions/v1/super-processor`

#### `ai-proxy` (pre-existing, not in repo)
- Referenced as having `RESEND_API_KEY` set — copy this value for `email-alerts`

---

## 7. Email Alert System (Sprint 10)

### Overview
8 alert types, all run through the single `email-alerts` edge function. Deduplicated via `email_log`. Branded HTML email template built by `buildEmail()` helper.

### Alert Types

| Alert | Trigger Condition | Dedup Key Pattern | Re-fires? |
|---|---|---|---|
| `cert_expiry` | 60 / 30 / 14 / 7 days before `expiry_date` | `cert_{id}_{days}d` | Never (once per window) |
| `rent_overdue` | 1 day after `next_rent_due` | `rent_overdue_{id}_{date}` | Never (once per due date) |
| `maintenance_overdue` | 7+ days with no update | `maint_overdue_{id}_{week}` | Weekly while unresolved |
| `awaab_law` | 14+ days open + damp/mould keyword | `awaab_{id}_{isoWeek}` | Weekly while unresolved |
| `mtd_deadline` | 30 / 14 / 7 days before submission deadline | `mtd_{id}_{days}d` | Never (once per window) |
| `insurance_expiry` | 60 / 30 days before policy expiry | `insurance_{id}_{days}d` | Never (once per window) |
| `compliance_score` | Score drops below 70% | `compliance_{landlord}_{date}` | Daily while below threshold |
| `weekly_summary` | Every Monday | `summary_{landlord}_{week}` | Weekly (new key each week) |

### Awaab's Law Keyword Detection
Matched keywords: `['damp', 'mould', 'mold', 'condensation', 'leak', 'water ingress', 'black mould']`
Used in: `email-alerts-index.ts` alert processor AND `tenant.html` AI priority assessor.

### Cron Schedule

| Job Name | Schedule (cron) | UTC Time | Action |
|---|---|---|---|
| `rentsafeai-daily-alerts` | `0 9 * * *` | 09:00 daily (10:00 BST / 09:00 GMT) | POST `{"type":"daily"}` to `email-alerts` |
| `rentsafeai-weekly-summary` | `0 8 * * 1` | 08:00 UTC Mondays | POST `{"type":"weekly_summary"}` to `email-alerts` |
| `rentsafeai-monthly-purge` | `0 2 1 * *` | 02:00 UTC on 1st of month | Calls `purge_old_email_logs()` |

### Monitoring Queries
```sql
-- Check cron job history
SELECT jrd.jobid, j.jobname, jrd.start_time, jrd.end_time, jrd.status, jrd.return_message
FROM cron.job_run_details jrd
JOIN cron.job j ON j.jobid = jrd.jobid
WHERE j.jobname LIKE 'rentsafeai%'
ORDER BY jrd.start_time DESC LIMIT 20;

-- Check emails sent
SELECT alert_type, COUNT(*) as sent_count, MAX(sent_at) as last_sent
FROM email_log GROUP BY alert_type ORDER BY last_sent DESC;

-- Clear test data (DEV ONLY — never run in prod)
TRUNCATE email_log;
```

---

## 8. Deployment Configuration

> **Critical:** PowerShell on Windows does not support `&&` for chaining commands.
> Run each command on a separate line.

### Static Frontend (GitHub Pages)
- **Repository:** `github.com/sddhawan79-lang/rentsafeai`
- **Hosting:** GitHub Pages, `main` branch, files served from root
- **Custom domain:** `rentsafeai.co.uk` (configured via `CNAME` file)
- **Deploy:** `git push origin main` — GitHub Pages auto-serves static files
- **No CI/CD pipeline** — manual push deploys immediately

### Edge Function Deployment
```powershell
# Step 1: Log in (only needed once per machine)
npx supabase login

# Step 2: Deploy email-alerts function
npx supabase functions deploy email-alerts --project-ref mahtcfukgzbonwibtsxz
```

**Pre-deploy checklist:**
1. Copy `email-alerts-index.ts` to `supabase/functions/email-alerts/index.ts`
2. Confirm `RESEND_API_KEY` secret exists in Supabase Dashboard

**Post-deploy verification:**
- Supabase Dashboard → Edge Functions → `email-alerts` → should be listed as Active
- Click function → check Logs panel is available

### Database Migrations
All migrations run manually in **Supabase → SQL Editor** (no automated migration tool).

| SQL File | Purpose | Order |
|---|---|---|
| `sprint10_step1_db.sql` | Creates `email_log`, `property_insurance`, `mtd_periods` tables; adds `next_rent_due` to `tenancies`; creates `get_compliance_score()` and `purge_old_email_logs()` functions | Run first |
| `sprint10_step1_fix.sql` | Patch/fix for Sprint 10 DB setup | Run after step1 |
| `sprint10_step2_cron.sql` | Sets up 3 pg_cron jobs — **must replace `YOUR_SERVICE_ROLE_KEY`** (2 occurrences) with actual service role key before running | Run last |
| `mtd_tables.sql` | Creates MTD module tables | Independent |

**Service role key location:** Supabase → Settings → API → `service_role` (secret key)

### Environment Secrets (Supabase Dashboard → Project Settings → Edge Functions → Secrets)
| Secret | Value source |
|---|---|
| `RESEND_API_KEY` | Copy from `ai-proxy` function — same key (`re_xxxxxxxxxxxxxxxxxxxxxxxx`) |

### DNS / Domain Configuration
- **Domain:** `rentsafeai.co.uk`
- **Hosting:** GitHub Pages (CNAME `sddhawan79-lang.github.io`)
- **Email sender:** `documents@rentsafeai.co.uk` via Resend
- **Pending:** SPF/DKIM records for Resend (email unreliable until resolved)
- **Pending:** GitHub Pages HTTPS / SSL certificate

---

## 9. Key Business Logic

### Compliance Scoring

**Client-side (`calcRAG()` in `landlord.html`):**
- Required certificate types: Gas Safety, EICR, Electrical, EPC, Energy, Deposit
- Deductions: -15pts expired cert, -10pts missing cert, -5pts cert due, -10pts missing critical type
- RAG thresholds: Green ≥80%, Amber ≥50%, Red <50%

**Server-side (`get_compliance_score()` PostgreSQL function):**
- Counts properties with no expired certs (excluding EPC) as a ratio
- Returns 0–100 rounded to 1 decimal place

### Section 8 Notice Generator (`moSection8()` in `landlord.html`)
- All 37 grounds under the Renters Rights Act 2025 (RRA 2025)
- Mandatory (`s8-badge-m`) vs Discretionary (`s8-badge-d`) classification
- 5-step wizard: pre-conditions → reason/category → ground selection → notice details → review
- Auto-calculates notice periods and court filing dates
- Output: Draft notice text only — handoff to GOV.UK Form 3A still required (pending item)

### Awaab's Law
- Triggered by damp/mould keyword match on maintenance description
- Keywords: `damp`, `mould`, `mold`, `condensation`, `leak`, `water ingress`, `black mould`
- Landlord email alert fires weekly if job remains unresolved after 14 days
- Visual flag (`awaab: true`) on maintenance record

### MTD Tax Logic (`mtd.html`)
- **Phase scope checker (`checkMTDScope()`):**
  - Gross income > £50,000: Phase 1 (mandatory Apr 2026)
  - Gross income > £30,000: Phase 2 (mandatory Apr 2027)
  - Gross income > £20,000: Phase 3 (mandatory Apr 2028)
- **Quarter status flow:** `not_started` → `in_progress` → `ready` → `submitted`
- **Section 24 calculator:** Compares full deduction (pre-2017) vs 20% tax credit (current law)
- **Expense categories (HMRC):** 7 categories available when logging expenses

### Tenant Portal Token System
- `invite_token` stored on the `tenants` record in Supabase
- Token passed via URL `?token=xxx` or read from `localStorage`
- No Supabase Auth required — access control via token lookup + RLS
- **Revocation:** Set `tenants.status = 'revoked'` → portal shows "Access revoked"
- E-sign flow triggered via `?esign=xxx` URL parameter → looks up `esign_requests` table

### Data Loading Pattern (`landlord.html`)
`loadData()` fires 10 parallel Supabase queries on startup:
`properties`, `tenants`, `certificates`, `maintenance`, `rent_payments`, `insurance`, `email_log`, `custom_templates`, `contractors`, `job_assignments`

---

## 10. Known Issues & Technical Debt

| # | Issue | Area | Status |
|---|---|---|---|
| 1 | HTTPS "Not secure" on rentsafeai.co.uk | GitHub Pages SSL | Pending |
| 2 | Resend SPF/DKIM records not set | Email delivery | Pending — emails unreliable |
| 3 | RRA PDF (GOV.UK Form 3A) not attached | Section 8 notices | Pending |
| 4 | Section 8 output is draft text only — handoff to Form 3A UI | UX | Pending |
| 5 | Email sending via `super-processor` (not dedicated function) | Architecture | Technical debt |
| 6 | PDF export via `window.print()` (not jsPDF) | Landlord dashboard | Technical debt |
| 7 | No tenant data input validation | Tenant portal | Technical debt |
| 8 | No offline/error recovery states | General | Technical debt |
| 9 | MX record missing for `rentsafeai.co.uk` | DNS / Email | Post-launch |
| 10 | Supabase credentials hardcoded in HTML files | Security hygiene | Acceptable — anon key is public-safe |

---

## 11. Pricing & Plans

| Plan | Monthly Price | Annual saving | Properties | Target user |
|---|---|---|---|---|
| Starter | £9.99/mo | 2 months free | Up to 3 | Accidental landlords |
| Landlord | £19.99/mo | 2 months free | Up to 5 | ★ Most popular |
| Portfolio | £39.99/mo | 2 months free | Unlimited | Portfolio landlords |

Annual billing: 2 months free (pay 10 months, get 12)

---

## 12. Feature Change Log

> Add an entry here whenever a new feature, modification, or architectural decision is made.
> Format: `## Sprint N — [Date] — Brief Title` followed by bullet points.

### Sprint 10 — Email Alert System
**Deployed:** See `SPRINT10_DEPLOY.md` for full deployment guide.
- Added `email_log` table with unique dedup index `(landlord_id, alert_type, reference_key)`
- Added `property_insurance` table with RLS
- Added `mtd_periods` table (scaffolded for accounting module)
- Added `next_rent_due` column to `tenancies`
- Added `get_compliance_score(landlord_id)` PostgreSQL function (0–100 scale)
- Added `purge_old_email_logs()` cleanup function (removes logs >18 months old)
- Deployed `email-alerts` Supabase Edge Function with 8 alert types
- Set up 3 pg_cron scheduled jobs: daily alerts, weekly summary, monthly purge
- **Pending outstanding items from Sprint 10:**
  - GitHub Pages SSL certificate
  - Resend SPF record
  - RRA PDF attachment
  - Section 8 → Form 3A UX handoff

### Sprint 11 — Tenant Portal (Planned)
**Goal:** Unique token-based URL per tenancy (no login required).
- Tenants can: view tenancy details, report maintenance issue (with photo upload), view open jobs, download latest certificates
- Uses existing `maintenance_jobs` and `certificates` tables
- All submissions create a row in `maintenance_jobs` and trigger landlord email alerts (Sprint 10 system)
