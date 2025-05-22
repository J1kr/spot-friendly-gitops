# Terraform for AWS EKS Test Environment

**이 디렉터리는 AWS Spot Instance를 활용한 Kubernetes 테스트 환경을 Terraform으로 프로비저닝하는 코드를 포함합니다.**   
개인 테스트 환경에서의 비용 최소화와 GitOps 워크플로우와의 원활한 통합을 목표로 합니다.

## 디렉토리 구조

```
terraform/
├── 00_base/                # 네트워크(VPC, Subnets), ACM, Terraform Backend 등 공통 인프라
├── 01_eks-cluster/         # EKS 클러스터, 노드 그룹, IRSA, 보안 그룹 등 클러스터 단위 리소스
├── 99_alarms/              # FIS 실험 템플릿, Slack 알림 Lambda 등 테스트 자동화 지원
└── scripts/                # EKS 클러스터 생성 후 ArgoCD 등록 등의 자동화 스크립트
```

## 프로젝트 개요

이 Terraform 코드는 AWS EKS 클러스터를 Spot 인스턴스 기반으로 구성하여 최소한의 비용을 사용하는 것을 목적으로 두었습니다.   
또한, EKS 클러스터 생성 후 ArgoCD에 자동으로 등록하여 재사용성에 초점을 두었습니다.

## 주요 구성 요소

**1. 인프라 레이어:**
-   **`00_base/`**: 모든 테스트 환경의 기반이 되는 공유 네트워크 인프라 및 Terraform 상태 관리 설정. (VPC, Public Subnets, ACM 등)
-   **`01_eks-cluster/`**: 실제 테스트가 실행되는 EKS 클러스터. (EKS Control Plane, 초기 노드 그룹, IRSA, 커스텀 보안 그룹 등)
-   **`99_alarms/`**: Spot 인스턴스 중단 시나리오 테스트 및 알림을 위한 리소스. (FIS 템플릿, Lambda, SQS/SNS)

**2. 패턴:**
-   **Terraform 모듈화**: 리소스의 라이프사이클과 비용 특성에 따라 모듈을 분리하여 관리 효율성 및 비용 최소화.
-   **커뮤니티 모듈 활용**: `terraform-aws-modules/vpc`, `terraform-aws-modules/eks` 등 모듈 사용.
-   **IRSA (IAM Roles for Service Accounts)**: Kubernetes 서비스 어카운트에 AWS IAM 역할을 안전하게 부여.
-   **`local-exec`을 이용한 자동화**: EKS 클러스터 생성 후 ArgoCD 등록 스크립트 자동 실행.
-   **Spot 인스턴스 사용**: 초기 노드 그룹 구성 Spot 사용.

## 시작하기

### 사전 요구사항

-   AWS CLI 및 적절한 IAM 권한 설정
-   Terraform CLI 설치
-   `kubectl` 설치
-   ArgoCD CLI 설치 및 대상 ArgoCD 서버 로그인 (ArgoCD 연동 스크립트 실행 시 필요)

### 배포 순서

1.  **공통 인프라 (`00_base`) 배포**
2.  **EKS 클러스터 (`01_eks-cluster`) 배포**
    *   *이 단계에서 EKS 클러스터 생성 후 `scripts/register-eks-to-argocd.sh` 스크립트가 자동으로 실행됩니다.*
3.  **테스트 자동화 리소스 (`99_alarms`) 배포**

### 리소스 제거 

테스트 후 `01_eks-cluster` 모듈의 리소스를 제거합니다. 해당 디렉터리에서 `terraform destroy`를 실행합니다.
*`00_base`의 리소스는 일반적으로 유지합니다.*

## 특징

-   **비용 최소화**: `00_base/vpc.tf`에서는 개인 테스트 환경의 비용을 줄이기 위해 NAT Gateway를 의도적으로 제외하고 Public Subnet만 사용합니다.
-   **커스텀 노드 보안 그룹**: `01_eks-cluster/sg-eksnode.tf`에 정의된 커스텀 보안 그룹을 EKS 노드에 적용하여, 필요한 통신 규칙을 세밀하게 제어합니다.
-   **IRSA 패턴 적용**: `01_eks-cluster/irsa-*.tf` 파일들을 통해 각 Kubernetes 애드온(ALB Controller, Karpenter 등)에 최소 권한 원칙에 따른 IAM 역할을 부여합니다.
-   **Karpenter와 SQS 연동**: `01_eks-cluster/sqs-karpenter.tf`는 Spot 인스턴스 중단 알림을 Karpenter가 수신할 수 있도록 SQS 큐를 설정하여, 선제적인 노드 관리를 지원합니다.

## Terraform 상태 관리

각 모듈의 Terraform 상태는 S3 버킷에 원격으로 저장됩니다. 개인 테스트 환경이므로 DynamoDB를 사용한 상태 잠금은 구성되어 있지 않습니다.    
협업 환경에서는 상태 파일의 일관성을 위해 DynamoDB 잠금 기능 추가를 권장합니다.

## 관련 문서

이 Terraform 프로젝트 및 전체 아키텍처에 대한 설명은 아래 링크에서도 확인할 수 있습니다
-   [Notion 상세 문서](https://jongone.notion.site/Spot-Friendly-Architecture-1eeed8530d818053b1e8c08b75ed04ca?pvs=74) (전체 프로젝트 개요 및 설계)
-   코드 내 주석 및 각 Terraform 파일 참조.