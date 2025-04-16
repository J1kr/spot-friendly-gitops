#!/bin/bash

set -e

CLUSTER_NAME="spot-friendly-cluster"
AWS_REGION="ap-northeast-2"

echo "🔐 [1] EKS 클러스터 kubeconfig 업데이트 중..."
aws eks update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}"

echo "🚀 [2] ArgoCD에 클러스터 등록 중..."
argocd cluster add "arn:aws:eks:${AWS_REGION}:$(aws sts get-caller-identity --query Account --output text):cluster/${CLUSTER_NAME}" \
  --name "${CLUSTER_NAME}" \
  --yes

echo "✅ 등록 완료: ${CLUSTER_NAME}"