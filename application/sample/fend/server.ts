import express, { Request, Response } from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import compression from 'compression';
import promClient from 'prom-client';
import { logger } from './src/logger';
import { initMetrics } from './src/metrics-init';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = process.env.PORT || 3000;

// ──────────────────────────────────────────────
// 🧭 1. Prometheus Metrics Setup
// ──────────────────────────────────────────────
const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics();

const customCounter = new promClient.Counter({
  name: 'frontend_requests_total',
  help: 'Total number of frontend HTTP requests',
  labelNames: ['method', 'route']
});

app.use((req: Request, res: Response, next) => {
  console.log(`[DEBUG] Incoming request: ${req.method} ${req.url}`);
  customCounter.inc({ method: req.method, route: req.path });
  next();
});

// 추가적인 메트릭 초기화 함수 호출
initMetrics(app);

// ──────────────────────────────────────────────
// 🧭 2. Serve React Static Files
// ──────────────────────────────────────────────
app.use(compression());
app.use(express.static(path.join(__dirname, 'dist')));

console.log('[DEBUG] Registering catch-all route handler');
app.get(/.*/, (req, res) => {
  console.log(`[DEBUG] Fallback route hit for ${req.path}`);
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});
logger.info('[확인용] 이건 pino 로그야');
console.debug('[확인용] 이건 콘솔 로그야');
// ──────────────────────────────────────────────
// ✅ Start Server
// ──────────────────────────────────────────────
app.listen(port, () => {
  console.log(`✅ Server listening on http://localhost:${port}`);
});