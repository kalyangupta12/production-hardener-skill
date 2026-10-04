# production-hardener

A reusable Agent Skill for evidence-driven production hardening of existing Next.js, React, Express, Fastify, Prisma/PostgreSQL, Redis, Docker, Coolify, Traefik, Vercel, Cloudflare, and VPS applications.

## What it does

- audits architecture before editing
- validates correctness before chasing benchmarks
- adds/uses observability to locate bottlenecks
- guides realistic k6 saturation testing
- hardens database/cache behavior
- reviews Next.js/React production performance
- checks Coolify/Traefik/Docker deployment topology
- decides when clustering/replicas are actually justified
- produces a defensible safe-capacity report

## Install with skills CLI

Once this repository is public on GitHub:

```bash
npx skills add OWNER/REPO
```

The skills.sh ecosystem installs skills from GitHub repositories through the skills CLI.

## Structure

```text
production-hardener/
├── SKILL.md
├── README.md
├── scripts/
│   └── quick-audit.sh
└── references/
    ├── backend-database.md
    ├── deployment-coolify.md
    ├── frontend.md
    ├── load-testing.md
    ├── scorecard.md
    └── security-reliability.md
```

## Suggested repository name

`production-hardener-skill`

## License

MIT
