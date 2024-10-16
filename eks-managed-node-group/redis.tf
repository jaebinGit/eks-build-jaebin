# Elasticache Subnet Group 생성 (기존 서브넷 사용)
resource "aws_elasticache_subnet_group" "redis" {
  name       = "ecom-subgroup-redis"
  subnet_ids = module.vpc.intra_subnets

  tags = {
    Name = "redis"
  }
}

# Redis 보안 그룹 생성
resource "aws_security_group" "redis_sg" {
  name        = "redis_security_group" 
  description = "Security group for Redis"
  vpc_id      = module.vpc.vpc_id # Redis 클러스터가 속한 VPC의 ID

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id] # EKS 노드의 보안 그룹을 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 모든 아웃바운드 트래픽 허용 (필요에 따라 제한 가능)
  }

  tags = {
    Name = "redis-security-group"
  }
}

# # Redis Replication Group 생성
# resource "aws_elasticache_replication_group" "redis" {
#   replication_group_id          = "ecom-redis-replication-group"
#   description                   = "Redis replication group for e-commerce application"
#   engine                        = "redis"
#   engine_version                = "7.1"
#   node_type                     = "cache.r5.large"
#   parameter_group_name          = "default.redis7.cluster.on"
#   port                          = 6379
#   subnet_group_name             = aws_elasticache_subnet_group.redis.name
#   security_group_ids            = [aws_security_group.redis_sg.id] # 위에서 생성한 Redis 보안 그룹
#   automatic_failover_enabled    = true
#   replicas_per_node_group       = 1  # 노드 그룹당 복제본 수
#   preferred_cache_cluster_azs   = ["ap-northeast-2a", "ap-northeast-2c"]  # 가용 영역 지정
#
#   tags = {
#     Name = "ecom-redis-replication-group"
#   }
# }
#
# # 출력: Redis 엔드포인트
# output "redis_endpoint" {
#   value = aws_elasticache_replication_group.redis.primary_endpoint_address
# }


# Redis Replication Group 생성 (최소 사양)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "ecom-redis-replication-group"
  description                   = "Redis replication group for e-commerce application"
  engine                        = "redis"
  engine_version                = "7.1"                    # 최신 Redis 버전
  node_type                     = "cache.t4g.micro"        # 최소 사양 인스턴스 (ARM 기반)
  parameter_group_name          = "default.redis7.cluster.on"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis_sg.id]

  automatic_failover_enabled    = false                    # 자동 장애 조치 비활성화 (비용 절감)
  replicas_per_node_group       = 0                        # 복제본 없이 단일 노드 그룹
  num_node_groups               = 1                        # 단일 노드 그룹

  tags = {
    Name = "ecom-redis-replication-group"
  }
}

# 출력: Redis 엔드포인트
output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}