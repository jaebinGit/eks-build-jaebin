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