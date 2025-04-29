# NodeGroup용 SG 생성
resource "aws_security_group" "node_sg" {
  name        = "${var.cluster_name}-node"
  description = "Custom SG for EKS NodeGroup"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
    "Name"                   = "${var.cluster_name}-node"
  }
}

# Control Plane → NodeGroup: 1025~65535 허용 (webhook, kubelet 등 포함)
resource "aws_security_group_rule" "allow_controlplane_to_node_ephemeral" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = module.eks.cluster_security_group_id
  description              = "Allow Control Plane to NodeGroup ephemeral TCP ports"
}

# Control Plane → NodeGroup: 443 포트 허용 (TLS webhook 등)
resource "aws_security_group_rule" "allow_controlplane_to_node_tls" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = module.eks.cluster_security_group_id
  description              = "Allow Control Plane to NodeGroup on port 443 (TLS webhook etc)"
}

# NodeGroup 간 통신 (CoreDNS, 서비스 디스커버리 등)
resource "aws_security_group_rule" "allow_node_to_node_ephemeral" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
  description               = "Allow Node to Node traffic on ephemeral TCP ports"
}

# CoreDNS UDP 포트 허용 (Node to Node)
resource "aws_security_group_rule" "allow_node_to_node_dns_udp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
  description               = "Allow Node to Node DNS UDP"
}

# CoreDNS TCP 포트 허용 (Node to Node)
resource "aws_security_group_rule" "allow_node_to_node_dns_tcp" {
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.node_sg.id
  description               = "Allow Node to Node DNS TCP"
}

# NodeGroup 아웃바운드 전체 허용
resource "aws_security_group_rule" "allow_node_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node_sg.id
  description       = "Allow all outbound traffic from NodeGroup"
}