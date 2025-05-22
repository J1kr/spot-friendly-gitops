#!/bin/bash

# FIS Experiment Template ID
TEMPLATE_ID="EXTCpm5ZX7HujNmVJ"

# 1. Locust 부하 테스트를 백그라운드로 실행
locust \
  -f locustfile.py \
  --headless \
  -u 300 \
  -r 50 \
  -t 5m \
  --host https://boutique.mogki.com &

LOCUST_PID=$!
echo "🚀 Locust 부하 테스트 시작 (PID: $LOCUST_PID)"

sleep 5 # Locust 안정화 대기

# 2. 5회 동안 1분마다 FIS 실험 트리거
REPEAT=5
SLEEP_SEC=60

for ((i=1; i<=REPEAT; i++))
do
  echo "🔧 [${i}/${REPEAT}] $(date '+%Y-%m-%d %H:%M:%S') - AWS FIS 실험 트리거 중..."

  aws fis start-experiment --experiment-template-id "$TEMPLATE_ID" --no-cli-pager

  echo "⏳ ${SLEEP_SEC}초 대기 중..."
  sleep ${SLEEP_SEC}
done

# 3. Locust 테스트가 끝날 때까지 대기
echo "✅ FIS 테스트 완료. Locust 종료까지 대기 중..."
wait $LOCUST_PID