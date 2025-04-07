// src/otel-init.ts
import { WebTracerProvider } from '@opentelemetry/sdk-trace-web';
import { BatchSpanProcessor, SimpleSpanProcessor } from '@opentelemetry/sdk-trace-base';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { ConsoleSpanExporter } from '@opentelemetry/sdk-trace-base';
import { ZoneContextManager } from '@opentelemetry/context-zone';
import { FetchInstrumentation } from '@opentelemetry/instrumentation-fetch';
import { registerInstrumentations } from '@opentelemetry/instrumentation';
import { getWebAutoInstrumentations } from '@opentelemetry/auto-instrumentations-web';
import { trace } from '@opentelemetry/api';

const provider = new WebTracerProvider({
  spanProcessors: [
    new BatchSpanProcessor(new OTLPTraceExporter({
      url: import.meta.env.VITE_OTEL_EXPORTER_URL,
    })),
    new SimpleSpanProcessor(new ConsoleSpanExporter())
  ]
});

provider.register({
  contextManager: new ZoneContextManager(),
});

registerInstrumentations({
    tracerProvider: provider,
    instrumentations: [
      getWebAutoInstrumentations(),
      new FetchInstrumentation({
        propagateTraceHeaderCorsUrls: /.*/,
      })
    ]
  });

export const tracer = trace.getTracer('bootstrap-frontend');

