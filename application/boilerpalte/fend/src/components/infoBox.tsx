import { useEffect, useState } from 'react';
import { fetchInfo } from '../api/fetchInfo';
import { tracer } from '../core/otel';
import { context, trace } from '@opentelemetry/api';
import { useTraceContext } from '../core/trace';

const InfoBox = () => {
  const [info, setInfo] = useState<any>(null);
  const { traceId, gtxId } = useTraceContext();

  useEffect(() => {
    const span = tracer.startSpan('InfoBox: fetch /api/info');
  
    context.with(trace.setSpan(context.active(), span), () => {
      fetchInfo(traceId, span.spanContext().spanId)
        .then(setInfo)
        .catch(() => {})
        .finally(() => span.end());
    });
  }, [traceId, gtxId]);

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

export default InfoBox;