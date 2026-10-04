# Coolify, Traefik, Docker, and VPS deployment playbook

## Principles

- Coolify typically lets Traefik own public 80/443.
- App containers should usually expose/listen on an internal port and let the proxy route to it.
- Do not publish DB/Redis ports publicly without an explicit requirement.
- Use persistent volumes/object storage for durable data.
- Treat containers as disposable.

## Frequent failure modes

### Wrong health check
A backend `/` may return 404 even when healthy. Provide `/health` that returns fast 200 without DB dependency.

### IPv4/IPv6 localhost mismatch
A container health check using `localhost` may resolve to `::1` while the service listens only on IPv4. Use an explicit compatible bind/address or configure both families appropriately.

### Wrong internal port
Traefik routes to the container's service port, not an arbitrary host port. Verify the application is actually listening there.

### Missing shared proxy network
A container can be healthy but unreachable by Traefik if it is not attached to the intended network.

### Port collision
Do not bind application containers to host 80/443 when Traefik owns them.

### 502 debugging order

1. container healthy/running
2. app listening on expected internal address/port
3. proxy and app share the required network
4. proxy can resolve the container/service
5. proxy service port is correct
6. inspect focused Traefik logs for connection refused/network/router errors

## Production topology

A practical client VPS can start with:

```text
Traefik
  -> API container
       -> PostgreSQL (private)
       -> Redis (private)
       -> Worker (private)
```

Frontend may remain on Vercel/CDN.

## Replica readiness

Before replicas:

- sessions must not depend on one process's memory
- uploads must not live only in ephemeral container FS
- caches/queues must be shared where needed
- DB connection pools must account for replica count
- graceful shutdown must stop accepting new work and close dependencies

## Backups

A deployment is not production-ready until backup **and restore** are both tested.
