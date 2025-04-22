module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "spot-friendly-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_dhcp_options    = true
  
  manage_default_network_acl = true
  manage_default_route_table = true
  manage_default_security_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                     = 1
    "karpenter.sh/discovery"                    = var.cluster_name  
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Name"                                      = "spot-friendly-vpc"
  }
}