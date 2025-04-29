output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_oidc_provider_url" {
  value = module.eks.oidc_provider
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "acm_certificate_arn" {
  description = "ARN of the wildcard ACM certificate for mogki.com"
  value       = aws_acm_certificate.wildcard_mogki.arn
}

output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter EC2 node IAM role"
  value       = aws_iam_role.karpenter_node.arn
}

output "mogki_acm_certificate_arn" {
  description = "ARN of the wildcard certificate for mogki.com"
  value       = aws_acm_certificate.wildcard_mogki.arn
}