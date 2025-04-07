// src/App.tsx
import { useEffect } from 'react';
import { context, trace } from '@opentelemetry/api';
import { tracer } from './otel-init';
import { logger } from './logger';

function App() {
  useEffect(() => {
    const span = tracer.startSpan('App: fetch /api/info');
    logger.info('[trace] started root span', { traceId: span.spanContext().traceId });
    logger.info('[otel] Exporter URL:', import.meta.env.VITE_OTEL_EXPORTER_URL);    
    context.with(trace.setSpan(context.active(), span), () => {
      fetch('/api/info', {
        method: 'GET',
        headers: {
          'traceparent': `00-${span.spanContext().traceId}-${span.spanContext().spanId}-01`
        }
      })
        .then(res => res.json())
        .then(data => {
          logger.info('[trace] /api/info response:', data);
          span.end();
        })
        .catch(err => {
          logger.error('[trace] error fetching /api/info:', err);
          span.end();
        });
    });
  }, []);

  return (
    <div className="App">
      <h1>Trace Bootstrap App</h1>
      <p>This is a frontend sample that emits a trace ID.</p>
    </div>
  );
}

export default App;
