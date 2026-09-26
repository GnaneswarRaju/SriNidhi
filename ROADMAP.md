# Roadmap

| Milestone | Deliverable | Gate |
|---|---|---|
| V0.1 | foundation, auth/roles, shell, local preferences, migrations, CI, design | local tests + RLS tests + review + remote CI |
| V0.2 | catalogue, unit conversion, stock ledger, adjustments, low stock | opening 10 + purchase 5 − sale 3 + return 1 − damage 1 = 12 |
| V0.3 | customers, representatives, suppliers | tenant-safe CRUD and history |
| V0.4 | purchases, stock-in, payable, payment/returns | all-or-nothing posting and reversal |
| V0.5 | vendor OCR review → purchase | human-confirmation gate and duplicate checks |
| V0.6 | POS, GST, discounts, mixed payment, invoice/returns | exact totals, concurrency and rollback |
| V0.7 | credit, allocation, due dates, overrides | allocation conservation, ledger reconciliation |
| V0.8 | handwritten bills → reviewed sale | uncertain fields and representative review |
| V0.9 | accounts, journals, expenses, closing | debit/credit equality and reconciliation |
| V0.10 | reports, filters, exports | report totals match ledgers |
| V0.11 | offline outbox, retry, conflict UI | restart/retry/duplicate/concurrency tests |
| V0.12 | beta, PostHog, performance and store trials | real devices/data, privacy review |
| V1.0 | deployment, monitoring, backups, recovery, releases | restore drill, signed builds and release approval |

Workflow: Backlog → Ready → Development → Code Review → Testing → Done → Released. A screen alone does not satisfy a milestone. Each significant slice uses an issue, branch, PR, validation evidence and changelog entry. Never label a milestone released while remote CI or mandatory deployment checks remain pending.
