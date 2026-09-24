# Local setup

## Prerequisites

- Flutter 3.47.5 / Dart 3.13.4 (pinned and verified against the official release manifest).
- Git, a supported browser, and Android SDK for Android builds. iOS builds require macOS/Xcode and signing.
- Supabase CLI plus Docker for the full local backend. Neither was present on the initial host.
- Node 22+ and pnpm for the optional PGlite SQL smoke test.

The initial host SDK is in ignored `.tools/flutter`; its package cache is `.tools/pub-cache`. Set `PUB_CACHE` to that path and add `.tools/flutter/bin` to PATH for this shell, or use your normal Flutter installation. Do not commit SDK archives/caches.

## Client

From `app/`:

```sh
flutter pub get --enforce-lockfile
dart run build_runner build
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze --fatal-infos
flutter test
```

Copy `config.example.json` to ignored `config.local.json`. Fill `SUPABASE_URL` and `SUPABASE_ANON_KEY` with a **publishable** or legacy **anon** key. These are public client identifiers, not authorization bypasses. Never use a secret/service-role key; the app rejects privileged key formats.

```sh
flutter run -d chrome --web-port=3000 --dart-define-from-file=config.local.json
flutter build web --release --no-web-resources-cdn --dart-define-from-file=config.local.json
```

An unconfigured build intentionally shows administrator setup. Use the separate development Supabase environment, not production, for initial testing. No sample user or password is shipped.

## Backend

From repository root, on a host with Docker and Supabase CLI:

```sh
supabase start
supabase db reset --local
supabase db lint --local --level warning --fail-on warning
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres -v ON_ERROR_STOP=1 -f supabase/tests/foundation.sql
```

The database test transaction rolls back its own fixtures. Do not run tests on production. For a linked development project, first inspect schema and migration history, then use `supabase link` and review `supabase db push --dry-run` before applying migrations. Do not apply blindly to an existing schema.

## Provisioning

Create/invite the first user through Supabase Auth administration. Keep sign-up disabled. Copy the resulting auth user UUID, then run `supabase/admin/provision_first_store.sql` using psql variables against the intended development database. This transaction creates one business, one branch, one membership and one owner grant. The role trigger writes an audit entry. The script is not a public RPC and does not embed a service key or password in Flutter.

## Web assets

`web/sqlite3.wasm` and `web/drift_worker.dart.js` are official Drift 2.35.0 assets, downloaded together and checked against GitHub's release digests. Provenance and SHA-256 values are in `scripts/web-assets.sha256`. Update them together when Drift changes. Serve WASM as `application/wasm`; HTTPS is required outside loopback development. Test COOP/COEP and browser persistence before enabling offline financial writes. An in-memory fallback is rejected by the foundation database connector.
