#!/bin/bash

set -e

CLUSTER_NAME="spot-friendly"
AWS_REGION="ap-northeast-2"
ALIAS_NAME="${CLUSTER_NAME}"
KARPENTER_ROLE_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/KarpenterNodeRole-${CLUSTER_NAME}"
CONTEXT_ARN="arn:aws:eks:${AWS_REGION}:$(aws sts get-caller-identity --query Account --output text):cluster/${CLUSTER_NAME}"

echo "🔐 [1] kubeconfig에 별칭으로 클러스터 추가 중..."
aws eks update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --alias "${ALIAS_NAME}"

echo "🚀 [2] ArgoCD에 alias로 클러스터 등록 중..."

argocd cluster add "${ALIAS_NAME}" \
  --name "${CLUSTER_NAME}" \
  --yes \
  --grpc-web

echo "✅ 클러스터 등록 완료: ${CLUSTER_NAME} (alias: ${ALIAS_NAME})"

echo "🔐 [3] aws-auth ConfigMap에 Karpenter Role 등록 중..."

# 기존 mapRoles 추출
EXISTING_MAPROLES=$(kubectl get configmap aws-auth -n kube-system -o json | jq -r '.data.mapRoles')

# 중복 등록 방지
if echo "$EXISTING_MAPROLES" | grep -q "${KARPENTER_ROLE_ARN}"; then
  echo "⚠️ 이미 해당 Role이 등록되어 있습니다. 중복 등록하지 않습니다."
  exit 0
fi

# 새 Role 정의
NEW_ROLE="
- rolearn: ${KARPENTER_ROLE_ARN}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes"

# 병합된 결과 생성
UPDATED_MAPROLES="${EXISTING_MAPROLES}"$'\n'"${NEW_ROLE}"

# patch용 ConfigMap 작성 및 적용
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
$(echo "$UPDATED_MAPROLES" | sed 's/^/    /')
EOF

echo "✅ Karpenter Role 등록 완료"