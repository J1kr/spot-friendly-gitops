const MetricsButton = () => {
    const handleClick = () => {
      const start = performance.now();
      requestAnimationFrame(() => {
        const end = performance.now();
        const latency = (end - start) / 1000.0;
        console.log(`[metrics] Button click latency: ${latency.toFixed(4)}s`);
  
        // prom-client에 등록된 이벤트로 자동 연결됨
      });
    };
  
    return (
      <button
        onClick={handleClick}
        style={{
          padding: '0.5rem 1rem',
          fontSize: '1rem',
          borderRadius: '6px',
          backgroundColor: '#4caf50',
          color: 'white',
          border: 'none',
          cursor: 'pointer',
          marginTop: '1rem'
        }}
      >
        📊 Click to simulate user interaction
      </button>
    );
  };
  
  export default MetricsButton;