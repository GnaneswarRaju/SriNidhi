# Changelog

## Unreleased — 0.2.0-dev.1 Catalogue

- Add product creation, editing, deactivation/reactivation, prefix search and keyset pagination with responsive navigation and forms.
- Normalize business categories/brands and provide immutable base units, optional barcodes/HSN/MRP, exact selling prices and reorder thresholds.
- Enforce roles in atomic Supabase functions, reject direct client writes, duplicate identifiers and stale edits, and audit successful mutations.
- Preserve create request identity across retries and compare money/quantities without floating-point arithmetic.
- Add database and widget contracts plus real Auth/PostgREST concurrent-write integration coverage.
- Use local responsive design previews with explicit user approval while Figma Starter tool quota blocks catalogue design sync.
- V0.2 inventory posting and low-stock evaluation remain unimplemented.

## 0.1.0 Foundation — merged 2026-09-26, not released

- Establish project specification, architecture, schema contracts and milestone roadmap.
- Define issue/PR workflow and Flutter/database CI.
- Add Flutter authentication, session route guards, verified branch selection, responsive navigation, theme and English localization.
- Add user-scoped Drift preferences and platform session storage; offline transaction posting remains scheduled for V0.11.
- Add business/branch membership, six branch roles, RLS, an immutable audit trail and trusted provisioning migration.
- Add sanitized diagnostics, configuration validation, security tests, accessibility checks, Figma references and rendered previews.
- Add a real Supabase Auth/PostgREST integration check for password login, refresh, branch access, membership revocation and sign-out in disposable CI.
- Connect the SriNidhi development backend, apply the foundation migrations, provision the first store owner and disable public sign-up.
- Correct the local Supabase email-provider setting so existing staff can sign in while global public registration remains disabled; test the effective Auth settings in CI.
- Harden the existing RLS event-trigger function grants and add missing foreign-key indexes. Align the unreleased foundation migration filename with its first hosted application timestamp.
- Document posting invariants, OCR human review, durable sync, backups, recovery, analytics and release gates.
- Foundation implementation and verification are tracked in `docs/testing/v0.1-verification.md`.

No production release or tag has been created.
