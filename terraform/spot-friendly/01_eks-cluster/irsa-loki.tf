resource "aws_iam_policy" "loki" {
  name        = "LokiS3Policy"
  description = "IAM Policy for Loki to access S3 bucket"
  path        = "/"
  policy = file("${path.module}/policy/loki-s3-policy.json")
}

module "loki_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "loki-irsa"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.loki.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:logging:loki"]
}

# (선택) Loki Helm values 수정 예정:
# serviceAccount:
#   name: loki
#   annotations:
#     eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/loki-irsa