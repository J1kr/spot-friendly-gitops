# ☁️ Spot-Friendly EKS with Karpenter (Terraform 기반 실험 환경)

이 리포지토리는 **AWS EKS + Karpenter 기반의 Spot 인스턴스 실험 인프라**를 구성합니다.  
비용 최적화와 **Stateless 아키텍처의 검증**을 목적으로 하며, GitOps 환경과 연계해 실험적으로 확장 가능합니다.

---

## 🚀 목표

- Spot 인스턴스 기반의 Karpenter 스케줄링 실험
- NAT Gateway 없이 퍼블릭 서브넷만으로 최소 비용 구성
- GitOps 기반 ArgoCD와 연계 (수동 등록)
- Stateless 워크로드의 graceful termination 실험 준비

---

## 📦 주요 구성 요소

| 구성 요소 | 설명 |
|-----------|------|
| **VPC** | 퍼블릭 서브넷만 사용하는 비용 최적화 구조 |
| **EKS Cluster** | IRSA 활성화, `spot-friendly-cluster` 이름 |
| **Karpenter** | Helm으로 설치, IAM Role + Provisioner 연계 |
| **Terraform Backend** | S3 (`j1-tfstate-eks`) 사용 |
| **ArgoCD 등록 스크립트** | `argocd cluster add` 자동화 `.sh` 포함 |

---

## 🧱 디렉터리 구조

```
terraform/spot-friendly/
├── backend.tf
├── main.tf
├── variables.tf
├── vpc.tf
├── eks.tf
├── karpenter-iam.tf
├── karpenter-install.tf
├── outputs.tf
└── scripts/
    └── register-eks-to-argocd.sh
```

---

## 🛠 실행 순서

```bash
# 1. backend.tf 기준으로 S3 연결
terraform init

# 2. 전체 인프라 생성
terraform apply

# 3. EKS kubeconfig 설정
aws eks update-kubeconfig \
  --region ap-northeast-2 \
  --name spot-friendly-cluster

# 4. ArgoCD 클러스터 등록
./scripts/register-eks-to-argocd.sh
```

> 💡 `argocd login`은 사전에 수동 로그인되어 있어야 합니다.

---

## 🔍 다음 단계

- [ ] `karpenter.sh/Provisioner` 배포
- [ ] 테스트 워크로드 생성
- [ ] Spot 중단 시 graceful termination 검증
- [ ] Metrics/Log 관측 (Prometheus + Thanos + Loki 예정)

---

## 📌 참고

- 기본 온디맨드 인스턴스는 가장 저렴한 4vCPU / 16GiB (`m6a.xlarge`)
- NAT Gateway는 사용하지 않으며, Karpenter 인스턴스는 퍼블릭 서브넷에 직접 생성됨
- 클러스터 이름: `spot-friendly-cluster`
- 리전: `ap-northeast-2`

---

> 이 프로젝트는 실험 목적의 Spot-Friendly 아키텍처를 구성하고, Stateless 기반 인프라 설계를 검증하는 데 초점을 맞춥니다.
