# 1. 빌드 단계: Vite로 프론트엔드 빌드
FROM node:18 AS builder

WORKDIR /app

COPY package.json package-lock.json ./
COPY .env .env
RUN npm install

COPY . .

# Vite로 React 앱 빌드 (dist 생성)
RUN npm run build


# 2. 런타임 단계: Express 서버만 실행
FROM node:18-slim

WORKDIR /app

# 런타임에 필요한 파일만 복사
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server.ts ./
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./
COPY --from=builder /app/tsconfig.json ./

# 필요 패키지만 설치
RUN npm install --omit=dev

# tsx로 서버 실행 (ts로 서버 돌릴 경우)
RUN npm install -g tsx

EXPOSE 3000

CMD ["tsx", "server.ts"]