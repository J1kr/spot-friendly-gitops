module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.11.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  subnet_ids = module.vpc.public_subnets
  vpc_id     = module.vpc.vpc_id

  enable_irsa = true

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

      labels = {
        node-role.kubernetes.io/bootstrap = "true"
        spot-friendly/on-demand           = "true"        
      }

      tags = {
        Name = "spot-friendly-bootstrap"
      }
    }
  }
}