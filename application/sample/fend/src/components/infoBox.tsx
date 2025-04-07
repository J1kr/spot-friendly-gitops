import { useEffect, useState } from 'react';
import { fetchInfo } from '../api/fetchInfo';
import { tracer } from '../otel-init';
import { context, trace } from '@opentelemetry/api';
import { logger } from '../logger';

export const InfoBox = () => {
  const [info, setInfo] = useState<any>(null);

  useEffect(() => {
    const span = tracer.startSpan('InfoBox: fetch /api/info');
    logger.info('[trace] started root span', { traceId: span.spanContext().traceId });

    context.with(trace.setSpan(context.active(), span), () => {
      fetchInfo(span.spanContext().traceId, span.spanContext().spanId)
        .then((data) => {
          logger.info('[trace] /api/info response:', data);
          setInfo(data);
        })
        .catch((err) => {
          logger.error('[trace] error fetching /api/info:', err);
        })
        .finally(() => {
          span.end();
        });
    });
  }, []);

  return (
    <div className="info-box">
      <h2>Backend Info</h2>
      {info ? (
        <pre>{JSON.stringify(info, null, 2)}</pre>
      ) : (
        <p>Loading info...</p>
      )}
    </div>
  );
};