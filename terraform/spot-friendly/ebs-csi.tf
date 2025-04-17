resource "aws_iam_policy" "ebs_csi" {
  name        = "EBSCSIPolicy"
  path        = "/"
  description = "IAM policy for EBS CSI Driver"
  policy      = file("${path.module}/iam/ebs-csi-policy.json")
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "spot-ebs-csi-irsa"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.ebs_csi.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "kubernetes_service_account" "ebs_csi_controller" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.ebs_csi_irsa.iam_role_arn
    }
  }
}

resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.26.1"
  namespace  = "kube-system"
  create_namespace = true

  values = [<<EOF  
driver:
  name: ebs.csi.aws.com
controller:
  serviceAccount:
    create: false
    name: ebs-csi-controller-sa
  nodeSelector:
    spot-friendly/on-demand: "true"
  tolerations:
    - key: "spot-friendly/on-demand"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"    
storageClasses:
  - name: ebs-sc
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
    volumeBindingMode: WaitForFirstConsumer
    reclaimPolicy: Delete
    parameters:
      type: gp3
      encrypted: "true"
EOF
  ]
}
