#!/bin/bash

set -e

CLUSTER_NAME="spot-friendly-cluster"
AWS_REGION="ap-northeast-2"
ALIAS_NAME="${CLUSTER_NAME}"
# 💡 Karpenter Role ARN 추출 (TF output에서 받아오거나 하드코딩)
KARPENTER_ROLE_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/KarpenterNodeRole-${CLUSTER_NAME}"

# 현재 context에 있는 arn
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
  --insecure

echo "✅ 클러스터 등록 완료: ${CLUSTER_NAME} (alias: ${ALIAS_NAME})"



echo "🔐 [3] aws-auth ConfigMap에 Karpenter Role 등록 중..."

# ConfigMap 백업
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-backup.yaml

# yq를 이용해 mapRoles에 Karpenter Role 추가
kubectl get configmap aws-auth -n kube-system -o yaml \
| yq e ".data.mapRoles += \"\n- rolearn: ${KARPENTER_ROLE_ARN}\n  username: system:node:{{EC2PrivateDNSName}}\n  groups:\n    - system:bootstrappers\n    - system:nodes\"" - \
| kubectl apply -f -

echo "✅ Karpenter Role 등록 완료"