resource "aws_ssm_parameter" "composer_username" {
  name  = "/magento/composer_username"
  type  = "String"
  value = var.composer_username
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "composer_password" {
  name  = "/magento/composer_password"
  type  = "SecureString"
  value = var.composer_password
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "cloudfrount_url" {
  name  = "/magento/cloudfrount_url"
  type  = "String"
  value = "http://${aws_cloudfront_distribution.app.domain_name}"
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "efs_mount_target" {
  name  = "/magento/efs_mount_target"
  type  = "String"
  value = aws_efs_mount_target.magento.0.dns_name
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_lb_address" {
  name  = "/magento/magento_lb_address"
  type  = "String"
  value = "http://${aws_lb.app.dns_name}"
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_admin_user" {
  name  = "/magento/magento_admin_user"
  type  = "String"
  value = var.magento_admin_user
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_admin_password" {
  name  = "/magento/magento_admin_password"
  type  = "SecureString"
  value = var.magento_admin_password
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_db_host" {
  name  = "/magento/magento_db_host"
  type  = "String"
  value = aws_db_instance.magento.address
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_db_name" {
  name  = "/magento/magento_db_name"
  type  = "String"
  value = var.magento_db_name
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_db_username" {
  name  = "/magento/magento_db_username"
  type  = "String"
  value = var.magento_db_username
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_db_password" {
  name  = "/magento/magento_db_password"
  type  = "SecureString"
  value = var.magento_db_password
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "magento_redis_host" {
  name  = "/magento/magento_redis_host"
  type  = "String"
  value = aws_elasticache_replication_group.magento.primary_endpoint_address
  tags  = var.common_tags
}
