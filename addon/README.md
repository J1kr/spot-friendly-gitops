
# 📦 addon

> 이 디렉터리는 **ArgoCD App of Apps 패턴**을 활용하여 Kubernetes 클러스터의 주요 Addon(애드온) 설치를 일괄 관리하는 리소스 정의 공간입니다.  
> 최상위 Root Application(예: `argoApps/root-addon/spot-addon.yaml`)이 하위 디렉터리 내 모든 Addon Application을 자동 동기화합니다.

## App of Apps 패턴 개요

- **Root Application**:  
  - 각 클러스터별로 `argoApps/root-addon/{cluster}-addon.yaml` 파일을 생성하여 모든 Addon(Application)을 일괄 등록/관리
  - `directory.recurse: true` 옵션으로 하위 Application 디렉터리 내 모든 리소스를 자동 동기화
  - 예시:
    - `argoApps/root-addon/spot-addon.yaml` : Spot 인스턴스 클러스터 Addon 일괄 관리
    - `argoApps/root-addon/mgmt-addon.yaml` : 관리 클러스터 Addon 일괄 관리

## 📁 디렉터리 구조
```
addon/
├── mgmt-local-cluster/         # 관리 클러스터용 Addon Application 정의
├── spot-friendly-cluster/      # Spot 클러스터용 Addon Application 정의
└── README.md
```

## 🛠️ 배포 방식

- 모든 YAML 파일은 **`kind: Application`(ArgoCD)** 리소스입니다.
- 각 Application은 외부 Helm Chart Repository에서 해당 Addon(예: Istio, Prometheus, ALB Controller 등)을 설치합니다.
- 필요한 values는 Application의 `spec.source.helm.values`에 **inline**으로 정의합니다.
- Addon들은 Helm values 파일을 따로 두지 않고, Application YAML 안에 필요한 값만 작성합니다.


## 📑 예시

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: alb-controller-spot
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://aws.github.io/eks-charts
    chart: aws-load-balancer-controller
    targetRevision: 1.12.0
    helm:
      values: |-
        clusterName: spot-friendly
        region: ap-northeast-2
        ...
  destination:
    name: spot-friendly
    namespace: kube-system
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```




## 🧩 운영 원칙  
- 	Helm Chart 관리: Addon은 공식 Helm Chart Registry에서 관리합니다. Chart 소스 자체는 커밋하지 않습니다.  
- 	중앙 집중형 관리: 모든 Addon 설치/업데이트는 ArgoCD Application 리소스를 통해 일괄적으로 관리합니다.  
- 	GitOps 준수: 변경 이력 및 배포 상태는 Git 리포지토리와 ArgoCD를 통해 완전 자동화/이력화합니다.  

## 📚 Addon 목록 예시

| 카테고리     | 애드온(Helm Chart)            | 주요 역할                   |
| ------------ | ---------------------------- | -------------------------- |
| 서비스 메시  | Istio                        | 트래픽 관리, 서비스 메시    |
| 인그레스     | AWS ALB Controller           | AWS ALB 연동                |
| DNS 자동화   | External DNS                 | Route53 레코드 자동화       |
| 스토리지     | AWS EBS CSI Driver           | EBS 볼륨 연동               |
| 인증서       | cert-manager                 | 인증서 관리/자동화          |
| 노드관리     | Karpenter                    | 노드 자동 프로비저닝        |
| 장애대응     | Node Termination Handler     | Spot 인스턴스 중단 감지     |
| 모니터링     | Prometheus, Thanos           | 모니터링, 장기 저장         |
| 로깅         | Loki, Promtail               | 로그 수집                   |
| 트레이싱     | Tempo                        | 분산 추적                   |

## 📄 참고  
- 실제 values 설정과 운영 관련 팁은 각 서브디렉터리(예: mgmt-local-cluster/, spot-friendly-cluster/)의 README.md에서 확인하세요.  
- 전체 Application의 관리 및 일괄 배포는 argoApps/ 디렉터리의 Root Application을 통해 동기화합니다.  

---