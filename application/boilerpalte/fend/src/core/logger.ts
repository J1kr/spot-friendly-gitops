import pino from 'pino';
import { context, trace } from '@opentelemetry/api';

const LOG_LEVEL = process.env.VITE_LOG_LEVEL || 'info';

function getCurrentTimestamp() {
  return new Date().toISOString();
}

function formatLog(level: string, msg: string, meta: Record<string, any>) {
  const timestamp = getCurrentTimestamp();
  const traceId = meta.trace_id ?? 'n/a';
  const spanId = meta.span_id ?? 'n/a';
  const gtxId = meta.gtx_id ?? 'n/a';
  return `${timestamp} ${level.toUpperCase().padEnd(5)} [fend-app] ${msg} | trace_id=${traceId} span_id=${spanId} gtx_id=${gtxId}`;
}

const rawLogger = pino({ level: LOG_LEVEL, base: null });

export const logger = {
  info: (msg: string, meta: Record<string, any> = {}) => {
    const span = trace.getSpan(context.active());
    const spanContext = span?.spanContext();
    meta.trace_id = spanContext?.traceId ?? 'n/a';
    meta.span_id = spanContext?.spanId ?? 'n/a';
    rawLogger.info(formatLog('info', msg, meta));
  },
  error: (msg: string, meta: Record<string, any> = {}) => {
    const span = trace.getSpan(context.active());
    const spanContext = span?.spanContext();
    meta.trace_id = spanContext?.traceId ?? 'n/a';
    meta.span_id = spanContext?.spanId ?? 'n/a';
    rawLogger.error(formatLog('error', msg, meta));
  },
};