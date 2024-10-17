# ALB 보안 그룹 생성
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTPS traffic from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow traffic to NodePort on worker nodes"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}

# EKS 워커 노드 보안 그룹에 인바운드 규칙 추가
resource "aws_security_group_rule" "allow_alb_to_nodeport" {
  type                     = "ingress"
  from_port                = 30080  # Istio Ingress Gateway의 NodePort 번호 시작
  to_port                  = 30080  # Istio Ingress Gateway의 NodePort 번호 끝
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = aws_security_group.alb_sg.id
  description              = "Allow ALB to access NodePort 30080"
}

# Ingress 리소스에서 ALB 보안 그룹 ID를 참조하도록 변수 설정
locals {
  alb_security_group_id = aws_security_group.alb_sg.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

# 워커 노드의 보안 그룹 ID를 변수로 설정
locals {
  worker_sg_ids = flatten([
    for ng in module.eks.eks_managed_node_group_security_group_ids :
    ng.value
  ])
}

# 워커 노드의 보안 그룹마다 보안 그룹 규칙 생성
resource "aws_security_group_rule" "allow_api_server_to_worker_nodes_ingress" {
  for_each = toset(local.worker_sg_ids)

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = each.value  # 워커 노드의 보안 그룹 ID
  source_security_group_id = module.eks.cluster_security_group_id  # 클러스터(API 서버)의 보안 그룹 ID
  description              = "Allow API server to communicate with worker nodes on port 443"
}