# Medusa shop (slimmed monorepo + standalone backend)
#
# - `packages/` — Medusa framework source (reference), dev-only bulk removed
#   (integration tests, docs site, design system, CI tooling).
# - `shop/` — the deployable Medusa v2 backend + admin dashboard.
#   Standalone npm project pinned to the framework version above.
#
# Quick start (production-like, needs Postgres + Redis):
#   cd shop && cp .env.example .env && npm install && npm run build
#   npx medusa db:migrate && npx medusa exec ./src/scripts/seed.ts
