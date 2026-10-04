#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

echo "== Production Hardener quick audit =="
echo "repo: $(pwd)"

echo "\n-- Package files --"
find . -maxdepth 2 \( -name package.json -o -name pnpm-lock.yaml -o -name yarn.lock -o -name package-lock.json \) -print 2>/dev/null | head -50

echo "\n-- Deployment files --"
find . -maxdepth 3 \( -name 'Dockerfile*' -o -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' -o -name 'compose.yml' -o -name 'compose.yaml' -o -name 'vercel.json' -o -name 'next.config.*' \) -print 2>/dev/null | head -100

echo "\n-- Environment templates --"
find . -maxdepth 3 \( -name '.env.example' -o -name '.env.sample' -o -name '*.env.example' \) -print 2>/dev/null | head -50

echo "\n-- Likely infrastructure dependencies --"
if command -v grep >/dev/null 2>&1; then
  grep -RIlE 'prisma|postgres|redis|bullmq|express|fastify|next|vite|traefik|cloudflare|razorpay|stripe' . \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=dist 2>/dev/null | head -100 || true
fi

echo "\nAudit discovery complete. Inspect findings before changing code."
