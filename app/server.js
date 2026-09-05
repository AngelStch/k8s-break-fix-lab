// orders-api: a deliberately small service with enough surface area to fail in interesting ways.
// Endpoints: /health, /orders, /orders (POST), /leak (allocates memory), /metrics
const http = require("http");
const { Pool } = require("pg");
const client = require("prom-client");

const PORT = Number(process.env.PORT || 8080);
const pool = new Pool({
  host: process.env.PGHOST,
  port: Number(process.env.PGPORT || 5432),
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  max: Number(process.env.PG_POOL_MAX || 10),
  connectionTimeoutMillis: 3000,
  idleTimeoutMillis: 10000,
});

client.collectDefaultMetrics();
const httpRequests = new client.Counter({
  name: "orders_http_requests_total",
  help: "HTTP requests by route and status",
  labelNames: ["route", "status"],
});
const dbErrors = new client.Counter({ name: "orders_db_errors_total", help: "Database errors by code", labelNames: ["code"] });
const leaked = [];

function log(level, msg, extra = {}) {
  console.log(JSON.stringify({ ts: new Date().toISOString(), level, msg, ...extra }));
}

async function ensureSchema() {
  await pool.query(`CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY, item TEXT NOT NULL, qty INT NOT NULL, created_at TIMESTAMPTZ DEFAULT now())`);
}

function send(res, status, body, route) {
  httpRequests.inc({ route, status });
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  try {
    if (url.pathname === "/health") return send(res, 200, { ok: true }, "/health");
    if (url.pathname === "/metrics") {
      res.writeHead(200, { "content-type": client.register.contentType });
      return res.end(await client.register.metrics());
    }
    if (url.pathname === "/orders" && req.method === "GET") {
      const { rows } = await pool.query("SELECT * FROM orders ORDER BY id DESC LIMIT 20");
      return send(res, 200, rows, "/orders");
    }
    if (url.pathname === "/orders" && req.method === "POST") {
      const { rows } = await pool.query("INSERT INTO orders(item, qty) VALUES ($1, $2) RETURNING *", ["widget", 1]);
      return send(res, 201, rows[0], "/orders");
    }
    if (url.pathname === "/leak") {
      // 10 MB per call, never released. Used by scenario 03.
      leaked.push(Buffer.alloc(10 * 1024 * 1024, 1));
      const mb = Math.round(process.memoryUsage().rss / 1024 / 1024);
      log("warn", "leak endpoint called", { rss_mb: mb });
      return send(res, 200, { rss_mb: mb, chunks: leaked.length }, "/leak");
    }
    return send(res, 404, { error: "not found" }, "404");
  } catch (err) {
    dbErrors.inc({ code: err.code || "unknown" });
    log("error", "request failed", { route: url.pathname, code: err.code, error: err.message, stack: err.stack });
    return send(res, 500, { error: err.message, code: err.code }, url.pathname);
  }
});

ensureSchema()
  .then(() => { server.listen(PORT, () => log("info", "orders-api listening", { port: PORT })); })
  .catch((err) => { log("error", "startup failed", { code: err.code, error: err.message }); process.exit(1); });

process.on("SIGTERM", () => { log("info", "shutting down"); server.close(() => pool.end().then(() => process.exit(0))); });
