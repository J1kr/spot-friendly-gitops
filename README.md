# Spot Instance 기반 아키텍처 프로젝트

**이 저장소는 AWS Spot Instance를 활용한 Kubernetes 아키텍처를 구현하기 위한 GitOps 리소스를 포함하고 있습니다.**

## 디렉토리 구조

```
.
├── addon                      # 클러스터 애드온 구성 요소   
│   ├── mgmt-local-cluster/    # 관리 클러스터용 애드온  
│   ├── spot-friendly-cluster/ # Spot 인스턴스 클러스터용 애드온  
│   └── README.md 
├── application                # 애플리케이션 배포 관련 파일  
│   ├── boilerpalte/           # 백엔드/프론트엔드 보일러플레이트  
│   ├── micro-demo/            # 마이크로서비스 데모 애플리케이션  
│   └── README.md  
├── argoApps                   # ArgoCD 애플리케이션 정의  
│   ├── mgmt-addon.yaml        # 
│   ├── micro-demo.yaml        #  
│   ├── spot-addon.yaml        #  
│   └── README.md 
└── terraform                  # 인프라 프로비저닝 코드  
    ├── README.md 
    └── spot-friendly
        ├── 00_base/           # 공통 인프라 리소스를 구성 (VPC,ACM)
        ├── 01_eks-cluster/    # EKS 클러스터 및 관련 IAM/IRSA 리소스 정의
        ├── 99_alarms/         # FIS Template, Slack 알림
        └── scripts/           # 생성된 EKS 클러스터를 ArgoCD에 등록하는 스크립트       
```


## 프로젝트 개요

이 프로젝트는 AWS Spot Instance를 활용하여 비용 효율적이면서도 안정적인 Kubernetes 기반 인프라를 구축하는 방법을 제시합니다. GitOps 방식으로 클러스터 관리 및 애플리케이션 배포를 자동화하였으며, Karpenter를 활용한 동적 프로비저닝과 Istio 서비스 메시를 통합하였습니다.

## 주요 구성 요소

**1. 클러스터 구조:**
- 관리용 클러스터(mgmt-local-cluster): 모니터링, 로깅, 트레이싱 등 ArgoCD
- Spot 인스턴스 클러스터(spot-friendly-cluster): 테스트 애플리케이션이 배포되는 환경

**2. 핵심 기술:**
- Karpenter,Node Termination handler: Spot 인스턴스 관리 및 노드 프로비저닝
- ArgoCD: GitOps 기반 애플리케이션 배포 
- Istio: 서비스 메시 및 트래픽 관리
- Terraform: 클라우드 인프라 프로비저닝

**3. Observability:**
- logging: Loki, Promtail
- metrics: Prometheus,Thanos 
- tracing: Tempo
- dashboard : Grafana

## 시작하기

사전 요구사항
- Local Kubernetes (k3d,minikube ..)
- AWS CLI 및 적절한 IAM 권한
- Terraform 
- kubectl, helm, argocd CLI

## 각 폴더별 상세 설명

각 주요 디렉토리에 대한 상세 설명은 해당 폴더의 README.md를 참조하세요:
- [addon/README.md](./addon/README.md): 클러스터 애드온 구성
- [application/README.md](./application/README.md): 테스트 애플리케이션 
- [argoApps/README.md](./argoApps/README.md): ArgoCD 애플리케이션
- [terraform/README.md](./terraform/README.md): 인프라 프로비저닝

## 관련 문서

이 프로젝트에 대한 더 자세한 내용은 다음 문서를 참조하세요:
- [포트폴리오 PDF](https://naver.me/GSc2lV36)
- [Notion 상세 문서](https://jongone.notion.site/Spot-Friendly-Architecture-1eeed8530d818053b1e8c08b75ed04ca?pvs=74)
