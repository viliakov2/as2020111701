resource "aws_elasticache_replication_group" "magento" {
  replication_group_id          = var.project_name
  replication_group_description = "The Multi-AZ Redis Master-Slave installation"
  automatic_failover_enabled    = true
  engine                        = var.cache_engine
  engine_version                = var.cache_engine_version
  node_type                     = var.cache_instance_type
  subnet_group_name             = aws_elasticache_subnet_group.cache.name
  security_group_ids            = [aws_security_group.cache.id]
  number_cache_clusters         = 2
  parameter_group_name          = var.cache_parameter_group_name
  port                          = 6379
  tags                          = var.common_tags
}

resource "aws_elasticache_subnet_group" "cache" {
  name       = var.project_name
  subnet_ids = aws_subnet.db.*.id
}

resource "aws_security_group" "cache" {
  name   = "${var.project_name}-cache"
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ "Name" : "${var.project_name}-cache" }, var.common_tags)
}

resource "aws_security_group_rule" "cache_app_ingress" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.cache.id
}

resource "aws_security_group_rule" "cache_bastion_ingress" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.cache.id
}
