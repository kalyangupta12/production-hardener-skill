# Frontend production hardening

## Next.js

- Identify App Router vs Pages Router and framework version.
- Inspect `use client` boundaries. Keep interactivity local; avoid turning large trees into client bundles.
- Detect data waterfalls. Prefer parallel server fetches where independent.
- Decide per route: static, ISR/revalidation, dynamic SSR, or client fetch. Do not make everything dynamic by default.
- Inspect route handlers/server actions for accidental backend responsibilities that should live in the API service.
- Check cache/revalidation semantics for authenticated vs public data.
- Avoid calling the public API through the internet from the same server when an internal path or direct service call is appropriate and architecture permits it.
- Measure bundle size before removing/replacing dependencies.
- Use framework image/font capabilities where they materially improve delivery.
- Lazy-load heavy client-only widgets.
- Check loading, error, not-found, and empty states.

## React / Vite

- Inspect bundle output and route splitting.
- Lazy-load large screens/widgets when appropriate.
- Avoid shipping server secrets or privileged logic through `VITE_*` environment variables.
- Ensure API URLs differ cleanly by environment.
- Configure SPA fallback at the web server/reverse proxy.
- Prefer CDN/static hosting for built assets.

## Browser/API concerns

- Set CORS intentionally; do not use wildcard credentials.
- Avoid storing long-lived sensitive tokens in unsafe browser storage without design justification.
- Validate CSP/security headers against the actual third-party script needs.
- Avoid unnecessary analytics/tracking libraries.
- Ensure frontend polling intervals do not create artificial API load.

## Vercel + external API VPS

- Distinguish browser-to-API traffic from Next server-to-API traffic.
- If Server Components/SSR call the VPS API, measure region-to-region latency.
- Prefer geographically sensible placement.
- Do not assume Vercel frontend scale solves backend/database capacity.
