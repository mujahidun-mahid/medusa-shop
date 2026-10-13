// TEMPORARY diagnostic probe (not production): reports container facts over
// HTTP so Render's health check passes and results are readable live.
const { execSync } = require("child_process");
const http = require("http");
const fs = require("fs");

const out = {};
try {
  out.redisBin = execSync("which redis-server").toString().trim();
} catch (e) {
  out.redisBin = "MISSING";
}
try {
  out.redisVersion = execSync("redis-server --version").toString().trim();
} catch (e) {
  out.redisVersion = "ERR: " + e.message.split("\n")[0];
}
try {
  out.adminFiles = fs.readdirSync("public/admin").slice(0, 5);
} catch (e) {
  out.adminFiles = "MISSING: " + e.message;
}
out.medusaServer = fs.existsSync(".medusa/server");
out.cwd = process.cwd();
out.env = {
  hasDb: !!process.env.DATABASE_URL,
  dbPrefix: (process.env.DATABASE_URL || "").slice(0, 24),
  hasRedis: !!process.env.REDIS_URL,
  redisUrl: process.env.REDIS_URL || null,
  port: process.env.PORT || null,
  nodeEnv: process.env.NODE_ENV || null,
};
out.node = process.version;

http
  .createServer((q, r) => {
    if (q.url === "/health") {
      r.statusCode = 200;
      r.end("OK");
      return;
    }
    r.setHeader("content-type", "application/json");
    r.end(JSON.stringify(out, null, 2));
  })
  .listen(process.env.PORT || 9000, () => console.log("probe up"));
