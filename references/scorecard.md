# Production readiness scorecard

Use this as a final review, not a substitute for measurements.

## Correctness
- [ ] critical writes are transactional or durably queued
- [ ] retries/webhooks are idempotent
- [ ] caches have documented consistency/invalidation
- [ ] async work cannot silently lose critical state

## Performance
- [ ] baseline and saturation tests exist
- [ ] per-route P95/P99 available
- [ ] realistic traffic mix
- [ ] external vendors isolated from capacity benchmark
- [ ] load generator separated for final capacity claim

## Node/API
- [ ] event-loop lag monitored
- [ ] no known blocking hot-path operations
- [ ] graceful shutdown
- [ ] request/external timeouts intentional
- [ ] logs appropriate for production load

## Database
- [ ] indexes match measured query patterns
- [ ] pool sizing intentional
- [ ] worker/replica multiplication accounted for
- [ ] slow queries/lock waits observable
- [ ] DB is private

## Redis/cache
- [ ] Redis failure degrades safely where applicable
- [ ] hot-key stampedes addressed if measured
- [ ] invalidation is targeted and correct

## Frontend
- [ ] client bundle measured
- [ ] client/server boundaries intentional
- [ ] data waterfalls addressed
- [ ] loading/error states implemented
- [ ] environment/API URLs correct

## Deployment
- [ ] health check returns real success
- [ ] internal ports/networking correct
- [ ] no unnecessary host ports
- [ ] persistent volumes/object storage
- [ ] TLS/DNS/proxy correct
- [ ] backups AND restore tested

## Capacity claim
Document:

- environment
- machine size
- worker count
- DB placement
- Redis placement
- load-generator placement
- traffic model
- max tested safe RPS/VUs
- P95/P99/error at safe capacity
- saturation point
- known limitations
