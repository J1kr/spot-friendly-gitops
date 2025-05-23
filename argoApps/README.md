# 🚀 ArgoCD GitOps Application Definitions

이 디렉터리는 ArgoCD를 기반으로 Kubernetes 클러스터에 배포할 리소스를 **GitOps 방식으로 선언적 관리**하기 위한 Application 정의들을 포함합니다.  
**App of Apps 패턴**을 활용하여 클러스터별로 Addon과 App들을 일괄 동기화할 수 있도록 구성되어 있습니다.  
디렉터리의 Application들은 자동 동기화 대상이 아니며, **ArgoCD UI나 CLI를 통해 직접 등록**해야 합니다.

## 📦 디렉터리 구성

| 디렉터리       | 설명 |
|----------------|------|
| `root-addon/`  | **Root Application 정의 디렉터리**입니다. <br>클러스터별 App of Apps가 위치하며, 각 클러스터에 필요한 Addon 또는 App들을 일괄 동기화합니다. |
| `apps/`        | 실제 서비스 또는 테스트용 **업무 애플리케이션 정의**가 위치합니다. <br>일부 앱은 관리 클러스터에 수동 또는 별도의 Root App을 통해 배포됩니다. |

> 📁 참고: 운영 Addon(Application)들은 별도의 [`addon/`](../addon/README.md) 디렉터리에서 관리되며, 자세한 내용은 해당 README를 참조하세요.

## 🧭 App of Apps 패턴 설명

- **Root App (`root-addon/{cluster}-addon.yaml`)** 은 지정된 디렉터리(예: `addon/spot-friendly-cluster`) 하위의 Application 정의들을 자동 탐색해 일괄 동기화합니다.
- `directory.recurse: true` 옵션을 통해 하위 Application들을 탐색하며, 실질적으로 ArgoCD Application을 선언적으로 관리하는 구조입니다.



## 📂 디렉터리 구조 예시


argoApps/
├── root-addon/
│   ├── spot-addon.yaml           # Spot 클러스터용 Root App
│   └── mgmt-addon.yaml           # 관리 클러스터용 Root App
├── apps/
│   └── micro-demo.yaml           # 테스트/운영용 App 정의 (예: microservices-demo)
└── README.md

## 📌 기타 사항

- `apps/` 내 모든 애플리케이션은 Helm 기반으로 정의되어 있으며, 필요 시 `values.yaml` 혹은 `values-<env>.yaml`을 통해 환경에 맞게 오버라이드됩니다.
- 일부 앱은 Root App을 통해 자동으로 동기화되며, 일부는 수동 동기화되거나 관리 클러스터에서 직접 배포됩니다.
