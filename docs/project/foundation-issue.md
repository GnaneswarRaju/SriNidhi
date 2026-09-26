# FOUND-001: Establish authenticated branch workspace

Milestone: [V0.1 Foundation](https://github.com/GnaneswarRaju/SriNidhi/milestone/1). Status: development web foundation verified against hosted Supabase; review in [PR #2](https://github.com/GnaneswarRaju/SriNidhi/pull/2). Remote issue: [FOUND-001 / #1](https://github.com/GnaneswarRaju/SriNidhi/issues/1).

Outcome: a configured store employee can sign in, view server-authorized branches, select a branch, navigate an adaptive workspace and sign out. An unconfigured install shows setup; a user without a branch sees a clear access message.

Acceptance: auth adapter/controller, route guards, backend RLS/roles, user-scoped persistent preference, responsive UI, privacy-safe logs, migrations, tests, docs, Figma references, feature commit, issue-linked PR and passing CI.

Database: `20260925032304_foundation.sql` and `20260925032910_harden_foundation_access.sql`, applied to the SriNidhi development project. The first owner is provisioned for Sri Nidhi Hardware / Main branch. Branch: `feature/v0.1-foundation`. No business transactions, OCR calls or analytics in this slice. Rollback: prior client; forward database correction. See verification report for actual completion evidence and unresolved external gates.
