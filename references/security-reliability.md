# Security and reliability checklist

## Secrets

- no production secrets committed
- separate development/test/production credentials
- redact secrets/tokens/payment signatures from logs
- rotate credentials after accidental exposure

## Network exposure

- public: reverse proxy / application endpoints only as required
- private: PostgreSQL, Redis, internal workers, admin-only internal services where possible
- firewall unnecessary ports

## HTTP

- intentional CORS
- request body limits
- rate limits for abuse-prone endpoints
- secure headers appropriate to app
- TLS at proxy/CDN
- explicit trusted proxy configuration when required

## Authentication/authorization

- verify authorization server-side
- do not confuse authentication with authorization
- scope expensive global auth middleware when public routes do not need it
- protect admin endpoints independently of UI visibility

## Reliability

- graceful shutdown
- bounded external-call timeout
- bounded retries with backoff where appropriate
- circuit-break/overload behavior where justified
- liveness independent of optional dependencies
- deeper readiness/dependency checks separately
- structured error logging
- persistent storage for user files
- backup + restore drill

## Overload behavior

Prefer controlled 429/503 behavior to requests sitting in memory for tens of seconds. Do not create unbounded queues.
