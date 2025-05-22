# 📦 application

이 디렉터리는 Kubernetes 환경 실험 및 운영을 위한 **샘플 애플리케이션(Boilerplate)** 과 **실험용 마이크로서비스(micro-demo)**를 포함합니다.  
각 폴더는 목적과 실험 환경에 맞게 구성되어 있으며, 실전 배포와 테스트에 초점을 맞췄습니다.

---

## 📁 디렉터리 구조
```bash
application/
├── boilerpalte/         # 백엔드/프론트엔드 보일러플레이트 (관측성, graceful shutdown 등 내장)
│   ├── bend/
│   └── fend/
└── micro-demo/          # Google Microservices Demo 기반 Helm Chart (Spot 실험 특화)
    └── micro-helm/
```

## 🧩 boilerpalte/

- **목적:**  
  - MSA 환경에서 *Tracing*, *Metrics*, *Logging*, *Graceful Shutdown* 등을 예제로 제공  
  - 각 서비스의 기본 동작 및 관측성 테스트, 실제 서비스에 참고용 베이스로 사용  
- **구성:**  
  - `bend/`: Spring Boot 기반 백엔드 (OTEL, logging, shutdown 등 내장)  
  - `fend/`: React + Express 기반 프론트엔드 (동일 관측성 패턴 적용)
- **특징:**  
  - OTEL 연동, Custom TraceID, 구조화 로깅, SIGTERM Graceful Shutdown 예시 포함  
  - **WIP(작업중)**: 실 서비스 연동보다 실험/예제용 코드 위주

*→ 각 서비스별 자세한 설명은 하위 README.md 참조*



## 🧩 micro-demo/

- **목적:**  
  - [Google Microservices Demo](https://github.com/GoogleCloudPlatform/microservices-demo)  
    Spot Instance 기반 장애 실험/무중단 복구 검증용 Helm Chart로 재구성  
- **구성:**  
  - Helm Chart (`micro-helm/`) + 부하테스트/자동화 스크립트(Locust, rollout 등)  
- **특징:**  
  - **관측성 연동**: Prometheus, Loki, Tempo, OTEL Collector 연동  
  - **실험 자동화**: 부하/롤링/인터럽트 자동화 스크립트 포함  
  - **K8s 특화 실험**: Rollout Restart, Graceful Shutdown, Spot Interrupt 대응 검증  
  - Spot + On-Demand 환경에서 실제 에러율/복구시간 측정, 실험 결과 Notion/PDF 참고

*→ 배포/실험/구성법은 `micro-demo/micro-helm/README.md` 참고*

---

## 📚 참고/NOTE

- **실제 실험 및 배포 방법, 파라미터 등은 각 하위 폴더의 README.md에서 상세 안내**
- 이 디렉터리는 실험과 DevOps 환경 구축, 관측성/무중단 배포 패턴의 실제 구현 예시에 초점

> ℹ️ 전체 아키텍처, 실험 결과, 설계 배경 등은 [Notion 문서](https://jongone.notion.site/Spot-Friendly-Architecture-1eeed8530d818053b1e8c08b75ed04ca?pvs=74) 및 포트폴리오 PDF 참고
