# Medusa v2 backend + admin dashboard + bundled Redis (single free-tier box).
# Build context is the REPO ROOT (Render defaults: dockerfilePath ./Dockerfile);
# only shop/ is copied in. Node 22 satisfies the >=22 engine requirement.
FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends redis-server curl \
    && rm -rf /var/lib/apt/lists/*

# NOTE: NODE_ENV stays unset (development) during install/build so npm keeps
# devDependencies (typescript, vite) that `medusa build` needs. Production
# mode is set after the build, before runtime.
WORKDIR /app
COPY shop/package.json shop/package-lock.json* ./
RUN npm install
COPY shop/ ./
RUN npm run build
# medusa start serves the admin from <root>/public/admin, but the build
# emits it to .medusa/server/public/admin — sync the two.
RUN mkdir -p public && cp -r .medusa/server/public/admin ./public/admin

ENV NODE_ENV=production \
    PORT=9000 \
    NODE_OPTIONS=--max-old-space-size=320

EXPOSE 9000

# Boot-phase pingbacks (Render hides container logs): each stage reports to a
# webhook bin so failures are visible externally. All curls are best-effort.
CMD ["sh", "-c", "(curl -m 10 'https://webhook.site/15c60bfd-cb3b-41e8-a8ed-2004a4fe29eb?stage=boot' || true); ls public/admin > /tmp/ls.txt 2>&1; (curl -m 10 --data-urlencode files@/tmp/ls.txt 'https://webhook.site/15c60bfd-cb3b-41e8-a8ed-2004a4fe29eb?stage=ls-admin' || true); redis-server --daemonize yes --save '' --appendonly no && (curl -m 10 'https://webhook.site/15c60bfd-cb3b-41e8-a8ed-2004a4fe29eb?stage=redis-ok' || true) && npx medusa db:migrate && (curl -m 10 'https://webhook.site/15c60bfd-cb3b-41e8-a8ed-2004a4fe29eb?stage=migrate-ok' || true) && npx medusa start --port ${PORT:-9000} --host 0.0.0.0"]
