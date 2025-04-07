//src/core/metrics-init.ts
import express, { Request, Response } from 'express';
import { Registry, collectDefaultMetrics, Gauge, Histogram } from 'prom-client';
import { onCLS, onFID, onLCP, onFCP, onTTFB, onINP } from 'web-vitals';

// 1. Prometheus 레지스트리 및 기본 메트릭 설정
const register = new Registry();
register.setDefaultLabels({ app: 'my-react-app' });
collectDefaultMetrics({ register });

// 2. 커스텀 메트릭 정의
const lcpMetric = new Gauge({
  name: 'frontend_lcp_seconds',
  help: 'Largest Contentful Paint (seconds)',
  registers: [register],
});
const clsMetric = new Gauge({
  name: 'frontend_cls_score',
  help: 'Cumulative Layout Shift (score)',
  registers: [register],
});
const fidMetric = new Histogram({
  name: 'frontend_fid_seconds',
  help: 'First Input Delay (seconds)',
  registers: [register],
  buckets: [0.001, 0.01, 0.1, 0.5, 1, 3],
});
const inpMetric = new Histogram({
  name: 'frontend_inp_seconds',
  help: 'Interaction to Next Paint (seconds)',
  registers: [register],
  buckets: [0.01, 0.1, 0.5, 1, 3, 5],
});
const pageLoadMetric = new Histogram({
  name: 'frontend_page_load_seconds',
  help: 'Page load time (navigation start to load event, seconds)',
  registers: [register],
  buckets: [0.1, 0.5, 1, 3, 5, 10],
});
const resourceLoadMetric = new Histogram({
  name: 'frontend_resource_load_seconds',
  help: 'Resource loading time (seconds)',
  registers: [register],
  buckets: [0.01, 0.1, 0.5, 1, 3, 10],
});
const uiInteractionMetric = new Histogram({
  name: 'frontend_interaction_latency_seconds',
  help: 'User interaction latency (seconds)',
  registers: [register],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1],
});

// 3. 웹 바이탈 측정값 수집 설정 (on 기반)
function setupWebVitalsCollection(): void {
  onLCP(metric => lcpMetric.set(metric.value / 1000.0));
  onCLS(metric => clsMetric.set(metric.value));
  onFID(metric => fidMetric.observe(metric.value / 1000.0));
  onINP?.(metric => inpMetric.observe(metric.value / 1000.0));
  onFCP(metric => {
    const fcpGauge = new Gauge({ name: 'frontend_fcp_seconds', help: 'First Contentful Paint (seconds)', registers: [register] });
    fcpGauge.set(metric.value / 1000.0);
  });
  onTTFB(metric => {
    const ttfbGauge = new Gauge({ name: 'frontend_ttfb_seconds', help: 'Time to First Byte (seconds)', registers: [register] });
    ttfbGauge.set(metric.value / 1000.0);
  });
}

// 4. 페이지 및 리소스 로딩 시간 측정
function recordLoadDurations(): void {
  if (performance && performance.getEntriesByType) {
    const [nav] = performance.getEntriesByType('navigation') as PerformanceNavigationTiming[];
    if (nav) {
      const loadTimeSec = (nav.loadEventEnd - nav.startTime) / 1000.0;
      pageLoadMetric.observe(loadTimeSec);
    }
    const resources = performance.getEntriesByType('resource') as PerformanceResourceTiming[];
    resources.forEach(res => {
      resourceLoadMetric.observe(res.duration / 1000.0);
    });
  }
}

// 5. 사용자 인터랙션 응답 시간 측정
function setupInteractionTracking(): void {
  document.addEventListener('click', () => {
    const startTime = performance.now();
    requestAnimationFrame(() => {
      const endTime = performance.now();
      const latencySec = (endTime - startTime) / 1000.0;
      uiInteractionMetric.observe(latencySec);
    });
  }, { passive: true });
}

// 6. Express 서버에 /metrics 엔드포인트 등록
export function initMetrics(app: express.Application): void {
  if (typeof window !== 'undefined') {
    setupWebVitalsCollection();
    recordLoadDurations();
    setupInteractionTracking();
  }

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
