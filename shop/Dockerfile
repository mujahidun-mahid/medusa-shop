# Medusa v2 backend + admin dashboard + bundled Redis (single free-tier box).
# Node 22 satisfies the >=22 engine requirement; Debian bookworm repos work.
FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends redis-server \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production \
    PORT=9000

WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
RUN npm run build

EXPOSE 9000

# Ephemeral in-container Redis (queues/cache; shop data lives in Postgres).
# Seed script is idempotent: it exits early when products already exist.
CMD ["sh", "-c", "redis-server --daemonize yes --save '' --appendonly no && npx medusa db:migrate && npx medusa exec ./src/scripts/seed.ts && npx medusa start --port ${PORT:-9000} --host 0.0.0.0"]
