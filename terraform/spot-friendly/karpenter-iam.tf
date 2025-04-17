data "aws_iam_policy_document" "karpenter_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  name               = "karpenter-controller-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_policy" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_vpc_controller_policy" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}