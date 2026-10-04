---
name: production-hardener
description: Audit and harden an existing Next.js, React, Express, Fastify, Prisma/PostgreSQL, Redis, Vercel, Docker, Coolify, Traefik, Cloudflare, or VPS application for production. Use when asked to make an existing web app production-ready, optimize performance safely, diagnose load-test failures, prepare a client deployment, review architecture, harden caching/database behavior, add observability/health checks, or validate scaling. Prefer measurement and correctness over benchmark chasing; do not add clustering, caches, replicas, or timeout increases without evidence.
license: MIT
compatibility: Designed for coding agents with repository read/write and shell access. Optional tools include Docker, k6, PostgreSQL client, Redis CLI, curl, jq, and git.
metadata:
  author: kalyan-gupta
  version: "1.0.0"
  category: production-engineering
---

# Production Hardener

Turn an existing web application into a defensible production deployment without blindly rewriting it.

The governing rule is:

> Measure first. Preserve correctness. Change only what evidence justifies. Re-test after every meaningful change.

## Scope

Activate this skill for repositories containing one or more of:

- Next.js or React frontends
- Express or Fastify APIs
- Prisma with PostgreSQL/MySQL
- Redis or BullMQ
- Vercel frontend deployment
- Docker / Docker Compose
- Coolify / Traefik
- Cloudflare DNS/proxy/CDN
- Linux VPS deployments
- k6 load testing

If the repository uses a different but analogous stack, adapt the workflow rather than refusing.

## Mandatory operating rules

1. **Inspect before editing.** Understand architecture, data flow, deployment topology, persistence, and external dependencies first.
2. **Do not benchmark external vendors as application capacity.** Mock payment/email/AI/SMS APIs only in explicit non-production load-test modes.
3. **Do not optimize by hiding overload.** Arbitrarily increasing timeouts, queues, DB pools, or retry counts is not a performance fix.
4. **Correctness beats throughput.** Never move financially critical or consistency-critical state updates to unsafe fire-and-forget work merely to improve latency.
5. **Do not add PM2/cluster/replicas/Kubernetes by reflex.** First prove CPU/event-loop saturation and verify DB/cache headroom.
6. **Treat VUs and RPS as different metrics.** Never claim that N k6 VUs means N simultaneous requests or N RPS.
7. **Separate the load generator for serious capacity claims.** Prefer k6 on a different machine from the application under test.
8. **Production topology matters.** Measure the topology that will actually ship: frontend region, API VPS, database location, Redis, proxy, and network path.
9. **Never expose the database publicly unless explicitly required.** Prefer private Docker/VPS networking.
10. **Preserve API contracts and user-visible behavior unless a bug requires change.**

## Phase 0 — Establish the intended production topology

Before changing code, identify:

- frontend hosting location (for example Vercel or same VPS)
- API hosting location
- database location
- Redis/cache location
- background worker location
- object/file storage location
- reverse proxy (Traefik/Nginx/etc.)
- DNS/CDN/proxy layer
- expected traffic pattern
- data durability and backup requirements
- payment/email/other external providers

If the intended deployment is a client VPS with Coolify, default to this mental model unless the repository says otherwise:

```text
Users
  -> CDN/DNS/proxy
  -> frontend (Vercel or static frontend)
  -> api.domain
  -> Traefik/Coolify
  -> Node API
       -> private PostgreSQL
       -> private Redis
       -> background worker
       -> object storage
```

Do not infer that a remote development database has the same latency/capacity as the future same-VPS production database.

## Phase 1 — Repository and architecture audit

Create a concise architecture report before edits.

Inspect:

- package manager and runtime versions
- app/framework versions
- client/server boundaries
- API routes/controllers/services
- middleware order
- auth middleware scope
- ORM/database initialization
- database pool configuration
- Redis setup and cache invalidation
- queues/workers
- file uploads and persistent storage
- external API calls
- logging
- health checks
- Dockerfiles/Compose
- proxy configuration
- environment variables and secret handling
- deployment scripts
- frontend bundle/data-fetching patterns

For Next.js/React frontend work, read `references/frontend.md`.
For Node/API/database work, read `references/backend-database.md`.
For Coolify/VPS work, read `references/deployment-coolify.md`.

Output before editing:

1. architecture summary
2. confirmed risks
3. suspected risks
4. files involved
5. proposed measurement plan
6. proposed changes ranked by impact and risk

## Phase 2 — Correctness and reliability audit

Before throughput optimization, identify correctness hazards:

- non-idempotent payment/webhook flows
- duplicate writes on retries
- critical updates dispatched with untracked fire-and-forget promises
- cache invalidation that can show materially stale financial/authorization data
- race conditions around read-after-write
- unbounded background jobs
- missing graceful shutdown
- missing request/external-call timeouts
- swallowed failures that can corrupt state
- uploads stored in ephemeral containers

For payment-like flows, require idempotency and durable state transitions. If asynchronous derived state is used, prefer durable jobs/outbox/reconciliation over untracked promises.

## Phase 3 — Observability baseline

Before load testing, ensure the system can answer *why* it slowed down.

At minimum collect:

### HTTP
- requests/sec
- status/error rate
- P50/P90/P95/P99
- latency per route

### Node
- CPU, preferably per core
- RSS and heap
- event-loop lag
- active sockets/connections
- process restarts

### Database
- pool size/usage/waiting
- active/idle connections
- query duration
- lock waits
- slow queries
- transaction duration

### Redis
- latency
- errors
- memory
- cache hit/miss where practical

Use a cheap liveness endpoint that does not depend on the DB. If a deep health endpoint exists, keep it separate and throttle/cache it.

## Phase 4 — Benchmark correctly

Read `references/load-testing.md` before modifying load tests.

Start with a realistic workload, not equal traffic to every endpoint.

For a typical public content/donation-style app, a starting distribution might be approximately:

- 80–85% public reads
- 8–10% forms/writes
- 3–5% payment/donation flow
- <=1% admin

Adjust to the actual product.

Run a saturation ladder, for example:

- 100
- 250
- 500
- 750
- 1,000
- 1,500
- 2,000
- 2,500
- 3,000 VUs

Record at every stage:

`VU | RPS | P50 | P90 | P95 | P99 | error% | CPU | event-loop lag | DB pool wait`

Identify:

- safe capacity
- knee of curve
- saturation point
- failure point

Do not call a test successful merely because the process did not crash.

## Phase 5 — Optimize only proven bottlenecks

Apply the smallest change that addresses measured evidence.

Common patterns, only when justified:

- missing/composite DB indexes for demonstrated query patterns
- reduce unnecessary DB round trips
- parallelize independent async work carefully
- short-lived cache for expensive public aggregates
- singleflight/request coalescing to prevent cache stampedes
- targeted cache invalidation instead of global wipes
- bounded concurrency
- durable background jobs for non-critical work
- disable noisy synchronous logging in benchmarks/production hot paths
- scope expensive auth middleware only where required
- avoid compressing tiny payloads
- correct keep-alive/socket configuration
- move CPU-heavy jobs off the request path

Never use a performance change that weakens data integrity without explicitly documenting and mitigating the tradeoff.

## Phase 6 — Frontend production hardening

If frontend work is in scope, read `references/frontend.md`.

Audit:

- client bundle size
- unnecessary `use client`
- server/client data waterfalls
- image/font delivery
- route-level loading/error states
- caching/revalidation strategy
- static vs dynamic rendering decisions
- third-party scripts
- Core Web Vitals risks
- API base URLs and environment separation
- CSP/security headers as appropriate
- source maps/error monitoring policy

Do not optimize the frontend by moving sensitive server logic into the browser.

## Phase 7 — Deployment hardening

If Docker/Coolify/VPS is in scope, read `references/deployment-coolify.md` and `references/security-reliability.md`.

Verify:

- health check uses a real success endpoint
- service binds to `0.0.0.0` inside container where required
- reverse proxy targets the correct internal port
- containers share the intended Docker network
- no unnecessary host port publishing
- DB/Redis are private
- persistent data uses volumes or external object storage
- backups and restore procedure exist
- secrets are environment-managed
- graceful shutdown works
- resource limits/reservations are intentional
- logs do not expose secrets
- DNS/Cloudflare proxy/TLS are coherent

For Traefik/Coolify, distinguish **container internal ports** from **host-published ports**. Avoid fighting the proxy for host 80/443.

## Phase 8 — Scaling decision

Scale only after a clean single-instance benchmark.

Recommend multi-worker Node/PM2/replicas only if evidence shows:

- one Node process saturates one CPU core or event-loop lag rises materially
- PostgreSQL still has headroom
- Redis still has headroom
- memory is stable
- the load generator is not competing on the same host

When adding workers, recalculate ORM connection pools:

`total_possible_db_connections ~= workers * pool_limit`

Do not accidentally multiply the database load past its safe limit.

Remember that an in-process singleflight `Map` becomes one singleflight domain **per worker**.

## Phase 9 — Production-like validation

Prefer the final benchmark on the intended Linux VPS topology, with k6 elsewhere.

For a typical Coolify deployment:

```text
Machine A: k6 load generator

Machine B / client VPS:
  Traefik
  Node API
  PostgreSQL
  Redis
  worker
```

If the frontend is on Vercel, also validate server-side calls from the deployed Next.js region to the VPS API where applicable.

Define a capacity claim using explicit SLO-like criteria, for example:

- HTTP error rate < 1%
- P95 below agreed target
- P99 below agreed target
- stable memory
- acceptable event-loop lag
- DB pool has headroom
- CPU has headroom

The exact latency target depends on endpoint type; do not impose one universal target on AI/reporting/payment operations and simple reads.

## Required final report

Produce:

### Architecture
What is deployed where and how requests/data flow.

### Problems found
Separate confirmed from suspected.

### Changes made
List file-by-file changes and reasons.

### Correctness assessment
Payment/write idempotency, cache consistency, persistence, retries, and crash safety.

### Performance results
Before/after table including RPS, P50/P95/P99, errors, CPU, event-loop lag, and DB metrics.

### Safe capacity
State the highest tested load meeting the agreed success criteria.

### Saturation point
State where latency/errors begin rising disproportionately.

### Remaining risks
Include anything that cannot be proven in the current environment.

### Scaling recommendation
Choose only from what evidence supports: no change, code/query work, cache, DB tuning, larger VPS, more Node workers, replicas/load balancing, separate DB/worker, or more advanced orchestration.

### Deployment checklist
Give exact remaining production steps.

## Stop conditions

Stop optimizing when:

- the product meets its target load with headroom
- improvements become marginal
- further throughput gains increase correctness/operational risk
- the next bottleneck requires a production-like environment rather than local tuning

Do not chase benchmark numbers for their own sake.
