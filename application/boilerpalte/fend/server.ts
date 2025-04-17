import './src/core/otel-node'; // Init OTEL first
import express, { Request, Response } from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import compression from 'compression';
import promClient from 'prom-client';
import fetch from 'node-fetch';
import { logger } from './src/core/logger';
import { initMetrics } from './src/core/metrics';
import { context, trace } from '@opentelemetry/api';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = process.env.PORT || 3000;

// ──────────────────────────────────────────────
// 🧭 1. Prometheus Metrics Setup
// ──────────────────────────────────────────────
promClient.collectDefaultMetrics();

const customCounter = new promClient.Counter({
  name: 'frontend_requests_total',
  help: 'Total number of frontend HTTP requests',
  labelNames: ['method', 'route'],
});

// 요청 로깅 미들웨어
app.use((req, res, next) => {
  logger.info(`Incoming request: ${req.method} ${req.originalUrl}`, {
    gtx_id: req.headers['x-gtx-id'] ?? 'n/a',
  });
  customCounter.inc({ method: req.method, route: req.path });
  next();
});

initMetrics(app); 

// ──────────────────────────────────────────────
// ✅ 2. API 프록시: /api/info → bend 서비스
// ──────────────────────────────────────────────
app.get('/api/info', async (req: Request, res: Response) => {
  const gtxId = req.headers['x-gtx-id'] ?? 'n/a';
  const tracer = trace.getTracer('fend-app');
  const span = tracer.startSpan('Proxy: GET /api/info');

  await context.with(trace.setSpan(context.active(), span), async () => {
    try {
      const backendRes = await fetch('http://api.j1-lab.local/api/info', {
        headers: {
          'x-gtx-id': typeof gtxId === 'string' ? gtxId : '',
        },
      });

      const data = await backendRes.json();
      logger.info('Proxied /api/info from bend', { gtx_id: gtxId });
      res.json(data);
    } catch (err) {
      logger.error('Error proxying /api/info', { error: err });
      res.status(500).json({ error: 'Internal Server Error' });
    } finally {
      span.end();
    }
  });
});

// ──────────────────────────────────────────────
// 🧭 3. 정적 파일 서빙
// ──────────────────────────────────────────────
app.use(compression());
app.use(express.static(path.join(__dirname, 'dist')));

// fallback route (SPA 대응용)
app.get(/.*/, (req, res) => {
  logger.info(`Fallback route hit for ${req.path}`, {
    gtx_id: req.headers['x-gtx-id'] ?? 'n/a',
  });
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// 초기화 로그
logger.info('[Startup] pino logger initialized');

// ──────────────────────────────────────────────
// ✅ Start Server
// ──────────────────────────────────────────────
app.listen(port, () => {
  logger.info(`✅ Server listening on http://localhost:${port}`);
});