import InfoBox from './components/infoBox';
import { logger } from './core/logger';
import { TraceProvider, useTraceContext } from './core/trace';

const AppContent = () => {
  const { traceId, gtxId } = useTraceContext();

  logger.info('📦 [App] Initialized', {
    trace_id: traceId,
    gtx_id: gtxId,
  });

  return (
    <main style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>🌐 Fend Bootstrap App</h1>
      <section style={{ marginBottom: '2rem' }}>
        <p>
          이 앱은 <strong>OpenTelemetry 기반의 트레이싱</strong>과{' '}
          <strong>Prometheus 메트릭 수집</strong> 기능을 실험하기 위한 프론트엔드 샘플입니다.
        </p>
        <p>Trace ID 및 GTX ID는 초기 렌더링 시 자동으로 생성되며, 모든 요청에 포함됩니다.</p>
      </section>
      <InfoBox />
    </main>
  );
};

const App = () => (
  <TraceProvider>
    <AppContent />
  </TraceProvider>
);

export default App;