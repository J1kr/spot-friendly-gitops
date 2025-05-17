resource "null_resource" "register_eks_to_argocd" {
  provisioner "local-exec" {
    command = "${path.module}/../scripts/register-eks-to-argocd.sh"
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    module.eks,                     # EKS 클러스터 생성 완료 후
    aws_iam_role.karpenter_node     # Karpenter용 Role 생성 완료 후
  ]
}