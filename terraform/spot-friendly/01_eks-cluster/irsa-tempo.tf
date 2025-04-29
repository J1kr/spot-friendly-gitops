resource "aws_iam_policy" "tempo" {
  name        = "TempoS3Policy"
  description = "IAM Policy for Tempo to access S3 bucket"
  path        = "/"
  policy      = file("${path.module}/policy/tempo-s3-policy.json")
}

module "tempo_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "tempo-irsa"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.tempo.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:tracing:tempo"]
}