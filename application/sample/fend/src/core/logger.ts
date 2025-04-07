//src/core/logger.ts
import pino from 'pino';
import { context, trace } from '@opentelemetry/api';

const LOG_LEVEL =
  typeof import.meta !== 'undefined' && import.meta.env?.VITE_LOG_LEVEL
    ? import.meta.env.VITE_LOG_LEVEL
    : process.env.VITE_LOG_LEVEL || 'info';

export const logger = pino({
  level: LOG_LEVEL,
  timestamp: pino.stdTimeFunctions.isoTime,
  formatters: {
    level(label: string) {
      return { level: label };
    },
    log(obj: Record<string, unknown>) {
      const span = trace.getSpan(context.active());
      const spanContext = span?.spanContext();
      return {
        ...obj,
        ...(spanContext && {
          trace_id: spanContext.traceId,
          span_id: spanContext.spanId,
        }),
      };
    },
  },
});