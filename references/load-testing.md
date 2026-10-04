# Load-testing playbook

## Terms

- **VU**: a virtual user executing the test scenario. It is not RPS.
- **RPS**: requests completed per second.
- **P50**: median latency.
- **P95**: 95% of measured requests complete at or below this latency.
- **P99**: 99% complete at or below this latency.

Average latency alone is insufficient because overload often appears first in tail latency.

## Test types

### Smoke
Low VUs. Verify scripts, assertions, auth, mocks, and basic correctness.

### Baseline
Measure low-load latency and throughput.

### Load
Expected production load.

### Stress/saturation
Increase load until the knee and failure point are visible.

### Spike
Sudden traffic increase. Use to test overload behavior, not normal capacity.

## Rate limiting

- Keep production rate limiting for production-realism and abuse tests.
- For raw capacity tests, bypass/raise it in a controlled non-production configuration.
- Never permanently disable rate limiting to make benchmarks pass.
- IP-based rate limiting can make many k6 VUs appear as one client.

## External providers

Do not repeatedly call real Razorpay/Stripe/email/SMS/AI APIs during backend capacity tests. Provide explicit non-production mocks and test vendor integration separately at realistic volume.

## k6 assertion safety

Network failures may produce null/empty bodies. Do not call `res.json()` unless a response/body exists and JSON parsing succeeds.

Tag requests by route so latency/error metrics are attributable.

## Realistic workload

Do not make every VU perform every operation equally. Model product behavior and think time.

## Saturation ladder

Run stable levels long enough to observe a trend. Example:

100 -> 250 -> 500 -> 750 -> 1000 -> 1500 -> 2000 -> 2500 -> 3000

Capture:

- RPS
- P50/P90/P95/P99
- errors
- server CPU
- event-loop lag
- memory
- DB pool usage/wait
- query/lock time
- Redis latency
- sockets/connections

## Interpreting results

A server that remains alive with 5% errors and 20s P95 is not "handling" that load well.

Look for the knee where additional concurrency causes disproportionate latency growth or throughput flattening/decline.

## Test topology

For defensible capacity numbers:

- load generator on Machine A
- application stack on Machine B

Do not let k6 compete for CPU with the server being measured unless the limitation is explicitly acknowledged.
