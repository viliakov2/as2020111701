output "lb_dns_name" {
  description = "The dns name of Application Load Balancer serving Magento application"
  value       = aws_lb.app.dns_name
}

output "cf_dns_name" {
  description = "The dns name of CloudFront distribution"
  value       = aws_cloudfront_distribution.app.domain_name
}

output "db_host" {
  description = "The dns name of Application Load Balancer serving Magento application"
  value       = aws_db_instance.magento.address
}

output "redis_host" {
  description = "The Redis cluster endpoint"
  value       = aws_elasticache_replication_group.magento.primary_endpoint_address
}

output "db_subnet_ids" {
  description = "The private database subnet ids"
  value       = aws_subnet.db.*.id
}

output "bastion_security_group_id" {
  description = "The Bastion host security group"
  value       = aws_security_group.bastion.id
}

output "app_security_group_id" {
  description = "The Application security group"
  value       = aws_security_group.app.id
}

output "vpc_id" {
  description = "The VPC id"
  value       = aws_vpc.vpc.id
}

output "app_iam_role" {
  description = "The Application IAM role"
  value       = aws_iam_role.app.name
}

output "app_route_table_ids" {
  description = "The private route table ids"
  value       = aws_route_table.private.*.id
}
