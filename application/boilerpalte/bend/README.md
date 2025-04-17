# bend-sample: Kotlin Spring Boot API with OpenTelemetry & Prometheus

## 소개
이 샘플 프로젝트는 Kotlin 기반 Spring Boot WebFlux 애플리케이션입니다. 다음과 같은 운영 기능을 기본으로 포함합니다:

- ✅ OpenTelemetry 연동 (Trace + Metrics)
- ✅ Prometheus Metrics 수집
- ✅ Spring Actuator 기반 Liveness, Readiness 설정
- ✅ Kubernetes 환경을 고려한 Graceful Shutdown

---

## 사용 기술 스택

- Kotlin + Spring Boot
- Gradle (Kotlin DSL)
- WebFlux (Reactive Web)
- OpenTelemetry SDK
- Micrometer + OTLP Exporter
- Prometheus + Grafana

---

## 주요 엔드포인트

| Path | 설명 |
|------|------|
| `/api/hello` | 테스트용 Hello API |
| `/actuator/health/liveness` | Liveness Probe |
| `/actuator/health/readiness` | Readiness Probe |
| `/actuator/prometheus` | Prometheus Metrics Export |

---

## 실행 방법

```bash
./gradlew bootRun
```

또는 Docker로 실행:

```bash
docker build -t bend-sample .
docker run -p 8080:8080 bend-sample
```

---

## Kubernetes 환경 구성 참고

### 🟢 Liveness & Readiness Probe 예시
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

---

## Graceful Shutdown

`application.yaml`에 다음 설정이 포함되어 있습니다:

```yaml
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
```

애플리케이션 종료 시 로그 전송, 메트릭 flush, 비즈니스 종료 처리 등을 안전하게 처리할 수 있도록 준비되어 있습니다.

---

## OTEL Collector 연동 설정
OTLP Exporter를 사용해 `/v1/metrics`, `/v1/traces` 로 OTEL Collector와 통신합니다. 
환경에 따라 `OTEL_EXPORTER_OTLP_ENDPOINT` 환경 변수를 사용하거나 `application.yaml`에 설정하세요.

---

## 참고

- [OpenTelemetry for Spring Boot](https://opentelemetry.io/docs/instrumentation/java/automatic/spring-boot/)
- [Micrometer Prometheus](https://micrometer.io/docs/registry/prometheus)
- [Spring Boot Actuator Docs](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)

---

> 이 프로젝트는 운영자 관점의 DevOps 온보딩 샘플을 목적으로 설계되었습니다.