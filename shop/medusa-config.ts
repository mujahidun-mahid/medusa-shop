import { loadEnv, defineConfig } from '@medusajs/framework/utils'

loadEnv(process.env.NODE_ENV || 'development', process.cwd())

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    // Supabase pooler presents a cert chain Node can't verify (SELF_SIGNED_CERT
    // IN_CHAIN in containers with strict TLS). Documented Medusa pattern for
    // managed Postgres: keep ?sslmode=require in the URL, skip verification.
    databaseDriverOptions: process.env.NODE_ENV !== "development" ?
      { connection: { ssl: { rejectUnauthorized: false } } } : {},
    redisUrl: process.env.REDIS_URL,
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  }
})
