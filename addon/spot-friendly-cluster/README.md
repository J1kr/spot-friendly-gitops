# ☁️ Spot-Friendly Cluster Addon Guide

이 디렉터리는 **Spot 인스턴스 기반 EKS 클러스터**의 핵심 Addon(애드온) 설정을 담고 있습니다.  
모든 애드온은 **ArgoCD Application** 리소스로 관리되며, Helm Chart 기반 공식 리포지터리를 참조합니다.


## 📁 디렉터리 구조

- **alb-controller/**:  
  - `alb-controller.yaml`: AWS ALB Ingress Controller(로드밸런서 연동)
  - `ingress-spot.yaml`: Istio Gateway와 연계한 ALB Ingress 리소스  
    - **주요 어노테이션 예시**
        ```yaml
        alb.ingress.kubernetes.io/target-node-labels: "elb-target=istio-gateway-node" #ALB-Istio 504 timoutout isuue
        alb.ingress.kubernetes.io/healthcheck-port: "30021"    # istio nodeport healthcheck
        alb.ingress.kubernetes.io/healthcheck-path: "/healthz/ready"  # istio nodeport healthcheck
- **cert-manager/**:  
  - `cert-manager.yaml`: 인증서 자동화 관리 (Helm Chart)
  - `cert-manager-certificate.yaml`: ALB Https <-> Istio Https 통신용 인증서 CRD 
- **ebs-csi/**:  
  - `ebs-csi.yaml`: EBS CSI 드라이버 (스토리지 연동)
- **external-dns/**:  
  - `external-dns.yaml`: Route53 DNS 자동 등록
- **istio/**:  
  - `istio-base.yaml`: Istio CRD/Base 컴포넌트 설치
  - `control-plane.yaml`: Istio Control Plane (istiod 등)
  - `gateway.yaml`: Gateway 리소스
  - `ingress.yaml`: IngressGateway 외부 트래픽 진입점 구성
    - ALB Healthcheck
    ```yaml
        type: NodePort
          ports:
            - name: status-port
              port: 15021
              targetPort: 15021
              nodePort: 30021  
- **karpenter/**:  
  - `karpenter.yaml`: Karpenter Controller 설치
  - `karpenter-node.yaml`: EC2NodeClass/NodePool 등 노드 정책
- **logging/**:  
  - `loki-stack.yaml`: Loki(로그 수집), Promtail 등 통합 로깅 스택
- **metrics-server/**:  
  - `metrics-server.yaml`: 메트릭 수집(K8s HPA/오토스케일러 지원)
- **monitoring/**:  
  - `prometheus-stack.yaml`: Prometheus, Grafana 등 모니터링
  - `istio.yaml`: Istio 트래픽/메시 모니터링용 ServiceMonitor 등
  - `thanos-objstore-secret.yaml`: Thanos S3 연동 설정
- **nth/**:  
  - `node-termination-handler.yaml`: Spot 인스턴스 중단 감지/대응
- **tracing/**:  
  - `tempo.yaml`: Grafana Tempo(분산 트레이싱)
  - `otel-collector.yaml`: OpenTelemetry Collector
  - `mesh-telemetry.yaml`: Istio 및 전체 서비스 Telemetry 수집

---

## 🔑 주요 Addon별 역할 및 설명

| 카테고리     | 디렉터리/파일                    | 설명                                                    |
| ------------ | -------------------------------- | ------------------------------------------------------- |
| 인그레스     | alb-controller/                  | ALB Ingress Controller, Istio Gateway 연동              |
| 인증서       | cert-manager/                    | 인증서 발급/자동화                                      |
| 스토리지     | ebs-csi/                         | EBS CSI 드라이버                                        |
| DNS          | external-dns/                    | Route53 자동화                                          |
| 서비스 메시  | istio/                           | 서비스 메시, 트래픽 관리, Ingress Gateway, mTLS 등      |
| 노드관리     | karpenter/                       | Spot/On-Demand 노드 오토스케일링, NodePool/EC2NodeClass |
| 장애대응     | nth/                             | Spot 노드 중단 감지/Drain 자동화                        |
| 모니터링     | monitoring/                      | Prometheus, Grafana, Thanos, ServiceMonitor 등          |
| 로깅         | logging/                         | Loki, Promtail 기반 로그 수집/조회                      |
| 트레이싱     | tracing/                         | Tempo, OTEL Collector, Mesh Telemetry                   |
| 메트릭       | metrics-server/                  | Kubernetes 리소스 메트릭 수집(HPA용)                    |

---

## 🛠️ 운영/설정 팁

- **Application 구조**  
  모든 Addon은 `kind: Application`으로 정의, 필요 values는 `spec.source.helm.values`에 인라인 삽입  
  별도의 values 파일을 두지 않아 관리가 단순함
- **IAM/ServiceAccount**  
  ALB, ExternalDNS, EBS-CSI, Karpenter 등 AWS 서비스 연동 Addon은 별도 IRSA/ServiceAccount와 Role이 필요  
  (Terraform 등 Infra 코드와 연계 관리)
- **Secret 관리**  
  Thanos 등 S3 연동이 필요한 서비스는 관련 Secret/YAML을 별도 정의하여 배포

---

## 🚩 **배포 방법**

1. **Root Application 등록**  
   - `argoApps/spot-addon.yaml` Root App에서 이 디렉토리 하위의 모든 Application을 자동 탐색/배포  
   - `directory.recurse: true` 방식
2. **ArgoCD UI/CLI에서 Sync**  
   - Root App → 전체 Addon 일괄 Sync  
   - 개별 Application만 선택해도 OK

---

## 📘 참고

- 각 YAML 별 **실제 values/설정**과, AWS 리소스 연동법은 소스 내 주석 또는 상위 README(프로젝트 루트/terraform 등) 참조
