output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnet_arns" {
  description = "ARNs of the public subnets"
  value       = module.vpc.public_subnet_arns
}

output "availability_zones" {
  description = "Availability Zones used by the VPC"
  value       = module.vpc.azs
}

output "default_security_group_id" {
  description = "Default security group ID of the VPC"
  value       = module.vpc.default_security_group_id
}

output "vpc_name" {
  description = "Name tag of the VPC"
  value       = module.vpc.name
}

output "acm_certificate_arn" {
  description = "ARN of the wildcard ACM certificate for mogki.com"
  value       = aws_acm_certificate.wildcard_mogki.arn
}

output "mogki_acm_certificate_arn" {
  description = "ARN of the wildcard certificate for mogki.com"
  value       = aws_acm_certificate.wildcard_mogki.arn
}
