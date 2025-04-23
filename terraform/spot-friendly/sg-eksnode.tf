# NodeGroup용 SG 생성
resource "aws_security_group" "node_sg" {
  name        = "spot-friendly-cluster-node-sg"
  description = "Custom SG for EKS NodeGroup"
  vpc_id      = module.vpc.vpc_id

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
    "Name"                   = "${var.cluster_name}-node-sg"
  }
}

# Control Plane → NodeGroup: 1025~65535 허용 (webhook, kubelet 등 포함)
resource "aws_security_group_rule" "allow_controlplane_to_node_ephemeral" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = module.eks.cluster_primary_security_group_id
  description              = "Allow all Control Plane to NodeGroup ephemeral TCP ports"
}

resource "aws_security_group_rule" "allow_controlplane_to_node_tls" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = module.eks.cluster_primary_security_group_id
  description              = "Allow Control Plane to NodeGroup on port 443 (TLS webhook etc)"
}

# NodeGroup 간 통신 (CoreDNS 등 필요시)
resource "aws_security_group_rule" "allow_node_to_node_ephemeral" {
  type              = "ingress"
  from_port         = 1025
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
  description       = "Allow Node to Node traffic on ephemeral TCP ports"
}

# CoreDNS UDP 포트 허용 (Node to Node)
resource "aws_security_group_rule" "allow_node_to_node_dns_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  security_group_id = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
  description       = "Allow Node to Node DNS UDP"
}

# CoreDNS TCP 포트 허용 (Node to Node)
resource "aws_security_group_rule" "allow_node_to_node_dns_tcp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  security_group_id = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
  description       = "Allow Node to Node DNS TCP"
}

resource "aws_security_group_rule" "allow_node_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node_sg.id
  description       = "Allow all outbound traffic from NodeGroup"
}