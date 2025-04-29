# EKS 클러스터 생성
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  subnet_ids = data.terraform_remote_state.base.outputs.public_subnet_ids
  vpc_id     = data.terraform_remote_state.base.outputs.vpc_id

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access          = false
  cluster_endpoint_public_access           = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  cluster_security_group_additional_rules = {
    ingress_nodes_443 = {
      description                = "Allow NodeGroup to access Control Plane on 443"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  create_node_security_group = false
  node_security_group_id     = aws_security_group.node_sg.id

  tags = {
    "Name" = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery" = var.cluster_name
  }

  eks_managed_node_groups = {
    bootstrap = {
      desired_size = 1
      min_size     = 1
      max_size     = 1

      instance_types = ["t3.xlarge"]
      capacity_type  = "SPOT"

      labels = {
        node-role = "managed"
        elb-target = "istio-gateway-node"
      }

      tags = {
        Name = "spot-friendly-bootstrap"
      }
    }
  }
}

# 기본 Addons 설치

resource "aws_eks_addon" "coredns" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "coredns"
  addon_version   = "v1.11.4-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    replicaCount = 1
  })

  depends_on = [module.eks]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "kube-proxy"
  addon_version   = "v1.31.3-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.eks]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "vpc-cni"
  addon_version   = "v1.19.3-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.eks]
}