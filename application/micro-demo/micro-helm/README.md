# 🛠️ Micro Demo (Helm Chart)

이 Helm Chart는 **Google Online Boutique**(microservices-demo)을 기반으로,
**AWS Spot-Friendly 아키텍처 실험**을 위해 구성되었습니다.

- 모든 서비스는 Kubernetes 친화적으로 설계되었으며,  
  Spot 환경에서의 테스트를 위해 구성되어 있습니다.
- 주요 서비스에는 **Graceful Shutdown, 트레이싱, 메트릭, 로깅** 설정이 적용되어 있습니다.

## ✅ 목적

- Spot Instance 환경에서의 무중단 서비스 실험 및 SLA 검증
- 다양한 언어별 **Graceful Shutdown** 동작/효과 실험
- **PodDisruptionBudget**, **podAntiAffinity** 등 고가용성(HA) 배포 패턴 검증
- ArgoCD/Helm 기반의 자동화 배포/운영 실습


## 📦 Graceful Shutdown 적용 대상 서비스

| 서비스               | 언어      | 종료 처리 방식                                               |
|----------------------|-----------|-------------------------------------------------------------|
| checkoutservice      | Go        | srv.GracefulStop() + SIGTERM, readiness 전환                |
| frontend             | Go        | http.Server.Shutdown() + SIGTERM, readiness 전환            |
| shippingservice      | Go        | srv.GracefulStop() + SIGTERM 처리                           |
| currencyservice      | Node.js   | process.on() + server.tryShutdown()                         |
| recommendationservice| Python    | KeyboardInterrupt 시 server.stop(grace=5).wait() 호출       |
| adservice            | Java      | Runtime.getRuntime().addShutdownHook() → server.shutdown()  |

## 📁 디렉터리 구조
```bash
micro-helm/
├── templates/
│   ├── {각 서비스}.yaml
│   └── …
├── values.yaml
├── values-spot.yaml
├── Chart.yaml
├── README.md
├── locustfile.py           # Locust 부하 테스트 스크립트
├── fis-loop-test.sh        # FIS 기반 Spot Interrupt 실험
├── run-load-and-rollout.sh # 롤링 리스타트+부하 자동화
```


## ⚙️ 주요 values 설정 예시

서비스별 replica, 이미지, 배치 정책(PDB/antiAffinity 등)은
**values.yaml** 또는 **values-spot.yaml**에서 설정합니다.

```yaml
frontend:
  enabled: true
  replicaCount: 3
  image:
    repository: dmogki/frontend
    tag: v0.1.1
  nodeSelector:
    node-role: spot
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values: [frontend]
          topologyKey: "kubernetes.io/hostname"
  pdb:
    enabled: true
    minAvailable: 1
```  
- replicaCount: 각 서비스 복제본 수
- nodeSelector/affinity: Spot 인스턴스 및 분산 배치 정책
- pdb: PodDisruptionBudget(최소 가용성 보장)  

모든 서비스의 상세 파라미터/구성은 values-spot.yaml을 참고하세요.

## 🧪 테스트/실험 스크립트
-	locustfile.py
    - Locust 기반 부하 테스트 (상품 탐색, 장바구니, 결제 등 시나리오 자동화)
-	run-load-and-rollout.sh
    -	5분간 Locust로 부하 생성 + 30초마다 rollout restart
    -	Graceful Shotdown 적용/미적용 상태 실험
-	fis-loop-test.sh
    - AWS FIS로 Spot Interrupt를 1분마다 발생시켜 실제 장애/복구 시나리오 재현

⚡ Helm 배포/실행 예시

## Helm 수동 배포
`helm install micro-demo ./micro-helm -n default --values values-spot.yaml`

## ArgoCD Application으로 GitOps 연동 
`argoApps/micro-demo.yaml`

📝 참고  
- 원본: Google Online Boutique  
- 본 차트는 Spot 환경 실험 및 장애내성 시나리오 최적화를 위해 리팩토링됨  
- 테스트 및 배포 시 실제 트래픽/비용이 발생할 수 있으니 환경 구성에 유의  