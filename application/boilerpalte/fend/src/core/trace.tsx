// src/core/trace.tsx
import { createContext, useContext, useMemo } from 'react';
import { v4 as uuidv4 } from 'uuid';
import { getOrCreateGtxId } from './gtx'; // ← 여기

const TraceContext = createContext<{ traceId: string; gtxId: string } | null>(null);

export const TraceProvider = ({ children }: { children: React.ReactNode }) => {
  const traceId = useMemo(() => uuidv4(), []);
  const gtxId = useMemo(() => getOrCreateGtxId(), []);

  return (
    <TraceContext.Provider value={{ traceId, gtxId }}>
      {children}
    </TraceContext.Provider>
  );
};

export const useTraceContext = () => {
  const context = useContext(TraceContext);
  if (!context) throw new Error('TraceContext not found');
  return context;
};