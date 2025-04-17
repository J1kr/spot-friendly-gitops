resource "aws_iam_policy" "external_dns" {
  name        = "ExternalDNSPolicy"
  path        = "/"
  description = "IAM policy for External DNS"
  policy      = file("${path.module}/iam/external-dns-policy.json")
}

module "external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "spot-external-dns-irsa"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:external-dns"]
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.external_dns_irsa.iam_role_arn
    }
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.13.1"
  namespace  = "kube-system"
  create_namespace = true

  values = [<<EOF
provider: aws
region: ap-northeast-2
nodeSelector:
  spot-friendly/on-demand: "true"
tolerations:
  - key: "spot-friendly/on-demand"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
serviceAccount:
  create: false
  name: external-dns
policy: sync
logLevel: info
domainFilters:
  - mogki.com
zoneIdFilters:
  - Z085777417FRXNQ15XG8A
interval: 1m
registry: txt
txtOwnerId: spot-friendly-cluster
sources:
  - ingress
EOF
  ]
}
