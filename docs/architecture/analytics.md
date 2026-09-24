# Beta analytics plan

No PostHog SDK or external analytics traffic in V0.1. Introduce around V0.12 after workflows stabilize. Analytics failures must never block posting or mutate transaction outcomes.

Allowlist events: sale_created, purchase_created, vendor_bill_scanned, handwritten_bill_scanned, ocr_review_opened, ocr_manual_correction, ocr_failed, partial_payment_created, customer_payment_received, sale_return_created, low_stock_alert_opened, offline_transaction_created, offline_sync_completed, offline_sync_failed. Properties limited to pseudonymous IDs, app version, module, latency bucket, state and sanitized error code.

Do not capture phone numbers, GSTIN, invoice contents, images, amounts, payment credentials or freeform notes. Disable autocapture/session replay by default on financial forms; review masking and consent requirements before enabling. Bound offline event queues and drop analytics safely. Feature flags may gate new UI/experiments, never divergent money/stock posting rules. Record retention, deletion, access and environment separation before beta.
