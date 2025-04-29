resource "aws_iam_role" "fis_karpenter" {
  name = "fis-karpenter"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "fis.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "fis-karpenter"
    eks  = "fis"
  }
}

# 기본 EC2 중단/종료 실험용 권한
resource "aws_iam_role_policy_attachment" "fis_ec2_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEC2Access"
  role       = aws_iam_role.fis_karpenter.id
}

# EKS 관련 API 실험용 권한 (예: Throttle, Unavailable 등)
resource "aws_iam_role_policy_attachment" "fis_eks_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEKSAccess"
  role       = aws_iam_role.fis_karpenter.id
}

# 실험용 커스텀 정책 (API 오류 주입 실험 확장)
data "aws_iam_policy_document" "fis_custom" {
  version = "2012-10-17"

  statement {
    sid    = "KarpenterApiFaultInjection"
    effect = "Allow"
    actions = [
      "fis:InjectApiInternalError",
      "fis:InjectApiThrottleError",
      "fis:InjectApiUnavailableError"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "fis_custom" {
  name   = "fis-karpenter-custom"
  policy = data.aws_iam_policy_document.fis_custom.json
}

resource "aws_iam_role_policy_attachment" "fis_custom_attachment" {
  role       = aws_iam_role.fis_karpenter.name
  policy_arn = aws_iam_policy.fis_custom.arn
}