export async function fetchInfo(traceId?: string, spanId?: string) {
    const headers: HeadersInit = {};
    if (traceId && spanId) {
      headers['traceparent'] = `00-${traceId}-${spanId}-01`;
    }
  
    const response = await fetch('/api/info', { headers });
    if (!response.ok) throw new Error('Failed to fetch /api/info');
    return response.json();
  }