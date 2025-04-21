module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  subnet_ids = module.vpc.public_subnets
  vpc_id     = module.vpc.vpc_id

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access = true

  eks_addons = {
    coredns = {
      addon_version     = "v1.11.1-eksbuild.4"
      resolve_conflicts = "OVERWRITE"
    }

    kube-proxy = {
      addon_version     = "v1.29.0-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }

    vpc-cni = {
      addon_version     = "v1.15.3-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
  }
  
  tags = {
    "Name" = var.cluster_name
  }

  eks_managed_node_groups = {
    bootstrap = {
      desired_size = 1
      min_size     = 1
      max_size     = 1

      instance_types = ["t3a.medium"]
      capacity_type  = "ON_DEMAND"
      
      tags = {
        Name = "spot-friendly-bootstrap"
      }
    }
  }
}
