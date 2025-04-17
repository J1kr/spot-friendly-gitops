// src/core/metrics.ts
import express, { Request, Response } from 'express';
import { Registry, collectDefaultMetrics, Counter } from 'prom-client';

// 1. Prometheus 레지스트리 및 기본 메트릭 설정
const register = new Registry();
register.setDefaultLabels({ app: 'fend' });
collectDefaultMetrics({ register });

// 2. 커스텀 메트릭 정의 (요청 수 카운터만 유지)
const httpRequestCounter = new Counter({
  name: 'frontend_http_requests_total',
  help: 'Total number of HTTP requests received by the frontend',
  labelNames: ['method', 'route'],
  registers: [register],
});

// 3. Express 서버에 /metrics 엔드포인트 등록
export function initMetrics(app: express.Application): void {
  app.use((req: Request, _res: Response, next) => {
    httpRequestCounter.inc({ method: req.method, route: req.path });
    next();
  });

  app.get('/metrics', async (_req: Request, res: Response) => {
    res.setHeader('Content-Type', register.contentType);
    try {
      const metrics = await register.metrics();
      res.end(metrics);
    } catch (err) {
      res.status(500).end(String(err));
    }
  });
}