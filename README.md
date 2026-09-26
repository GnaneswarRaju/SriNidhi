# Sri Nidhi · Hardware Store Management

A Flutter application for a hardware store, backed by Supabase PostgreSQL and a local Drift database. **V0.1 Foundation is merged**; **V0.2 begins with the product catalogue**. Inventory posting, POS, credit, OCR and accounting follow in separate vertical slices.

## Current scope

V0.1 establishes authentication, business/branch membership, server-enforced roles, responsive navigation, theme, localization infrastructure, structured diagnostics, local persistence, migrations and CI. It does not post business transactions or claim to be ready for store operations.

The catalogue adds product creation, editing, deactivation, prefix search and pagination. Prices and quantities use exact decimals; retries cannot create duplicates, and competing edits require refresh. See [INV-001](https://github.com/GnaneswarRaju/SriNidhi/issues/3) and the [catalogue contract](docs/features/products.md). Opening stock and stock balances are not implemented yet.

## Repository

Private source repository: [GnaneswarRaju/SriNidhi](https://github.com/GnaneswarRaju/SriNidhi). Foundation work: [FOUND-001](https://github.com/GnaneswarRaju/SriNidhi/issues/1).

| Path | Responsibility |
|---|---|
| `app/` | Flutter client: Riverpod, go_router, Drift and Supabase |
| `supabase/` | Versioned schema and database security tests |
| `docs/` | Decisions, feature contracts, testing, operations and design |
| `scripts/` | Repeatable developer checks |
| `.github/` | CI, issue forms and PR checklist |

Read [PROJECT_SPEC.md](PROJECT_SPEC.md), [ARCHITECTURE.md](ARCHITECTURE.md), [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md), [ROADMAP.md](ROADMAP.md) and [CHANGELOG.md](CHANGELOG.md) before modifying code.

## Development

Install the pinned Flutter SDK and follow [local setup](docs/deployment/local-setup.md). From `app/`, run `flutter pub get`, `dart run build_runner build`, `flutter gen-l10n`, `flutter analyze`, and `flutter test`. Use `flutter run -d chrome --dart-define-from-file=config.local.json` with a private configuration file copied from `config.example.json`.

Without Supabase configuration the app shows a setup screen, never a simulated authenticated store. No production credentials or sample financial data are included.

## Workflow

`main` is the reviewed integration branch. Current work uses `feature/v0.2-inventory`, linked issues, Conventional Commits and pull requests. No significant implementation is pushed directly to `main`. See [GitHub workflow](docs/decisions/007-git-workflow.md).

## Design

[Figma foundation](https://www.figma.com/design/cKRnPv2HAhhmYjsZ8iWPoW). Design decisions and implementation parity are tracked in [design foundation](docs/design/foundation.md).

The user approved [local catalogue previews](docs/design/catalogue-preview.html) while the Figma Starter tool quota is exhausted. Figma catalogue sync remains pending; see [catalogue design notes](docs/design/catalogue.md).

## Status

The development web app is connected to the SriNidhi Supabase project. Real Owner sign-in, branch/role loading, reload session restoration and sign-out have been verified. Public registration is disabled; staff access is provisioned through trusted administration. With the configured release build, run `node scripts/serve-preview.mjs` from the repository root and open `http://127.0.0.1:3000`.

See [the verification report](docs/testing/v0.1-verification.md) for checks actually executed, external dependencies and release blockers. An authored CI workflow is not evidence of a passing CI run.
