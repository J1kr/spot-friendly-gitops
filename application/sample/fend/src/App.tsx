// src/App.tsx
import { InfoBox } from './components/infoBox';
import { logger } from './logger';

function App() {
  logger.info('[app] App component initialized');

  return (
    <div className="App" style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>🌐 Trace Bootstrap App</h1>
      <p>
        이 앱은 프론트엔드에서 OpenTelemetry를 사용하여
        <strong> 백엔드 API 요청 </strong>에 대한 트레이스를 생성하고,
        <strong> 로그 및 메트릭 수집 </strong>까지 테스트할 수 있습니다.
      </p>
      <InfoBox />
    </div>
  );
}

export default App;