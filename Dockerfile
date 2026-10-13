# Medusa v2 backend + admin dashboard + bundled Redis (single free-tier box).
# Build context is the REPO ROOT (Render defaults: dockerfilePath ./Dockerfile);
# only shop/ is copied in. Node 22 satisfies the >=22 engine requirement.
FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends redis-server \
    && rm -rf /var/lib/apt/lists/*

# NOTE: NODE_ENV stays unset (development) during install/build so npm keeps
# devDependencies (typescript, vite) that `medusa build` needs. Production
# mode is set after the build, before runtime.
WORKDIR /app
COPY shop/package.json shop/package-lock.json* ./
RUN npm install
COPY shop/ ./
RUN npm run build

ENV NODE_ENV=production \
    PORT=9000 \
    NODE_OPTIONS=--max-old-space-size=320

EXPOSE 9000

# Ephemeral in-container Redis (queues/cache; shop data lives in Postgres).
# DB is migrated + seeded externally; boot only re-runs the no-op migrate.
CMD ["sh", "-c", "redis-server --daemonize yes --save '' --appendonly no && npx medusa db:migrate && npx medusa start --port ${PORT:-9000} --host 0.0.0.0"]
