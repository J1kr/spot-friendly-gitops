resource "aws_iam_policy" "cert_manager" {
  name        = "CertManagerPolicy"
  path        = "/"
  description = "IAM policy for Cert Manager"
  policy      = file("${path.module}/policy/cert-manager-policy.json")
}

module "cert_manager_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "spot-cert-manager-irsa"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cert-manager"]
}

resource "kubernetes_service_account" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.cert_manager_irsa.iam_role_arn
    }
  }
  depends_on = [module.eks]
}

