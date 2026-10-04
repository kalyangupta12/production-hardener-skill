# Backend, database, cache, and worker hardening

## Node/Express/Fastify

Inspect:

- middleware ordering and global middleware cost
- body size limits
- auth applied to public routes unnecessarily
- synchronous filesystem/crypto/CPU-heavy work
- sequential awaits that are truly independent
- error handling
- request/external-call timeouts
- keep-alive behavior
- graceful shutdown
- logging backpressure/noise

Do not assume Node being single-threaded means it is the bottleneck. Measure per-core CPU and event-loop lag.

## Prisma/PostgreSQL

Separate three timings where possible:

1. connection acquisition / pool wait
2. SQL execution
3. transaction duration

Review:

- pool limit and timeout
- workers × pool limit
- long interactive transactions
- N+1 patterns
- repeated aggregates
- missing indexes
- full scans/sorts
- unnecessary columns/joins
- lock contention on shared rows/counters

Do not solve pool exhaustion by only increasing the pool. The database has a finite connection/compute budget.

When backend and PostgreSQL will share one VPS/private network, benchmark that topology rather than assuming a remote development DB result represents production.

## Cache

Good candidates include expensive public aggregates and read-heavy content that tolerates bounded staleness.

Require:

- explicit TTL
- safe invalidation strategy
- authorization-aware keys
- cache failure fallback
- stampede protection when hot keys expire

### Singleflight

An in-process `Map<key, Promise>` can deduplicate identical concurrent misses inside one process. Ensure cleanup in `finally`, safe rejection handling, and bounded key behavior.

With multiple processes, each worker has its own Map. Do not claim distributed singleflight unless Redis/distributed locking is actually implemented.

## Financial/payment correctness

- verification/capture must be idempotent
- duplicate webhooks/retries must not duplicate increments
- critical state changes should be transactional or durably queued
- email is non-critical and can be async
- financial aggregates should not rely on untracked fire-and-forget promises
- if aggregates are eventually consistent, use a durable queue/outbox and reconciliation path

## Workers

Use background workers for work not needed to complete the HTTP response, such as email, image processing, report generation, and non-critical audit enrichment.

Ensure jobs are:

- durable where required
- idempotent
- retry-bounded
- observable
- not allowed to overwhelm the same database during spikes
