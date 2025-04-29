resource "aws_iam_policy" "thanos" {
  name        = "ThanosS3Policy"
  description = "IAM Policy for Thanos to access S3 bucket"
  path        = "/"
  policy      = file("${path.module}/policy/thanos-s3-policy.json")
}

module "thanos_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "thanos-irsa"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.thanos.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:thanos"]
}