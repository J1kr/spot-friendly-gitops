#!/bin/bash

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

# 2. 3분 동안 30초마다 rollout restart
REPEAT=9
SLEEP_SEC=30

for ((i=1; i<=REPEAT; i++))
do
  echo "🔄 [${i}/${REPEAT}] $(date '+%Y-%m-%d %H:%M:%S') - Restarting deployments..."

  kubectl rollout restart deployment frontend checkoutservice -n default
  
  echo "⏳ Waiting ${SLEEP_SEC} seconds before next restart..."
  sleep ${SLEEP_SEC}
done

# 3. Locust 테스트가 끝날 때까지 대기
echo "✅ Rollout 완료. Locust 테스트 완료 대기 중..."
wait $LOCUST_PID