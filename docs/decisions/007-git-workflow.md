# ADR-007: Git and GitHub workflow

Accepted. Private repository `hardware-store-management`; stable reviewed `main`; feature branches per version and focused fix/docs branches. Git is initialized before application code. The initial documentation commit seeds main locally; all implementation follows on `feature/v0.1-foundation`.

Issue prefixes: FOUND, INV, STOCK, PARTY, PURCHASE, OCR, SALE, CREDIT, ACCOUNT, REPORT, SYNC, OPS, BUG. Title example: `FOUND-001: Establish authenticated branch workspace`. Labels: type, area, priority; milestones: V0.1–V1.0. A slice carries acceptance, permissions, migration, design, validation and rollback evidence.

Before commit: read six root documents and relevant feature docs; inspect existing code, format, analyze, test and review staged diff. Commit convention `feat(auth): ...`. PR links issue; require Flutter CI and Database CI. No force-push, no feature development on main, no failed-test merges. Tag semantic versions only after all release gates pass. Configure branch protection after private remote creation; no claim it exists until verified.
