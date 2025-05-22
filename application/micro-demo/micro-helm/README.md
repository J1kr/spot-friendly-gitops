# Micro Demo (Helm Chart)

이 Helm Chart는 **Google의 Online Boutique** 마이크로서비스 데모를 참고하여 Spot-Friendly 테스트를 위한 목적으로 구성되었습니다.  
각 서비스에는 **Graceful Shutdown** 로직이 포함되어 있으며, 실제 서비스 종료 동작을 확인하기 위해 로그를 통해 검증할 수 있습니다.

---

## ✅ 목적

- Spot 환경에서 안정적인 서비스 종료 검증
- 다양한 언어 기반 마이크로서비스의 graceful termination 방식 실험
- Helm 기반 배포 구조 정립

---

## 📦 마이크로서비스 목록

| 서비스 이름             | 언어      | 종료 방식                                   | 로그 확인 | 비고                            |
|-------------------------|-----------|---------------------------------------------|-----------|----------------------------------|
| `checkoutservice`       | Go        | `srv.GracefulStop()`                   | ✅         | gRPC 서버 종료                    |
| `shippingservice`       | Go        | `srv.GracefulStop()`               | ✅         | Redis 사용                        |
| `adservice`             | Java      | `Runtime.getRuntime().addShutdownHook()`    | ✅         | gRPC 서버 stop 메서드 호출        |
| `emailservice`          | Python    | `server.stop(5).wait()`                     | ✅         | 실제 메일 전송 없음 (dummy)       |
| `currencyservice`       | Node.js   | `server.tryShutdown()`                      | ✅         | gRPC만 존재                       |
| `recommendationservice` | Python    | `server.stop(5).wait()`                     | ✅         | dummy logic                       |
| `paymentservice`        | Node.js   | `server.tryShutdown()`                      | ✅         | OpenTelemetry 연동                |
| `productcatalogservice` | Go        | `srv.GracefulStop()` 사용                   | ✅         | 단순 JSON 파일 읽기               |
| `frontend`              | Go        | `http.Server.Shutdown()` 사용               | ✅         | HTTP 기반 프론트엔드             |

---

## 📁 구조

```bash
micro-helm/
├── templates/
│   ├── adservice.yaml
│   ├── cartservice.yaml
│   ├── checkoutservice.yaml
│   ├── currencyservice.yaml
│   ├── emailservice.yaml
│   ├── frontend.yaml
│   ├── istio.yaml
│   ├── loadgenerator.yaml
│   ├── paymentservice.yaml
│   ├── productcatalogservice.yaml
│   ├── recommendationservice.yaml
│   ├── redis.yaml
│   └── shippingservice.yaml
├── values.yaml
└── Chart.yaml
```

---

## ⚙️ 주요 values 설정 예시

```yaml
frontend:
  enabled: true
  image:
    repository: dmogki/frontend
    tag: v0.0.0
  nodeSelector: {}
  affinity: {}
  tolerations: []
  topologySpreadConstraints: []

loadgenerator:
  enabled: true
  image:
    repository: us-central1-docker.pkg.dev/google-samples/microservices-demo/loadgenerator
    tag: v0.10.2
  env:
    users: "15"
    rate: "2"
  resources:
    requests:
      cpu: 300m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

> 🧩 각 서비스의 `resources`는 Helm 템플릿에 **하드코딩되어 있으며 변경 불가능**합니다.  
> Spot 스케줄링 전략 (nodeSelector, affinity 등)은 values.yaml을 통해 조정 가능합니다.

---

## 🛠 배포 예시

```bash
helm install micro-demo ./micro-helm -n default
```

혹은 ArgoCD를 통해 GitOps 방식으로도 배포할 수 있습니다.

---

## 📝 참고

- 원본: [Google Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo)
- 이 Helm 차트는 Spot Instance 환경에서의 테스트를 목적으로 리팩토링되었습니다.
