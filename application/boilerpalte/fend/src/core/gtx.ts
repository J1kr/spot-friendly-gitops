// src/core/gtx.ts
import { v4 as uuidv4 } from 'uuid';

const KEY = 'gtx_id';

export const getOrCreateGtxId = (): string => {
  if (typeof window === 'undefined') return uuidv4(); // SSR 방어

  const existing = localStorage.getItem(KEY);
  if (existing) return existing;

  const newId = uuidv4();
  localStorage.setItem(KEY, newId);
  return newId;
};