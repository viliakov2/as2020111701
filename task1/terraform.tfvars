aws_region   = "us-east-1"
project_name = "assessment"
common_tags = {
  CostCenter  = 1981
  Owner       = "Me"
  Application = "Webshop"
  Environment = "test"
}

vpc_cidr          = "10.0.0.0/16"
vpc_front_subnets = ["10.0.0.0/25", "10.0.0.128/25"]
vpc_app_subnets   = ["10.0.1.0/25", "10.0.1.128/25"]
vpc_db_subnets    = ["10.0.2.0/25", "10.0.2.128/25"]

ec2_key_name             = "assessment"
app_instance_type        = "t3.medium"
app_asg_min_size         = 1
app_asg_max_size         = 4
app_desired_capacity     = 2
bastion_instance_type    = "t3.micro"
bastion_asg_min_size     = 1
bastion_asg_max_size     = 1
bastion_desired_capacity = 1

rds_allocated_storage = 20
rds_engine            = "MariaDB"
rds_instance_class    = "db.t2.micro"
magento_db_name       = "magento"
magento_db_username   = "magento"
magento_db_password   = "magento1234"
rds_engine_version    = "10.4"
rds_multi_az          = false

cache_engine               = "redis"
cache_engine_version       = "5.0.6"
cache_instance_type        = "cache.t2.micro"
cache_parameter_group_name = "default.redis5.0"

magento_admin_user     = "admin"
magento_admin_password = "admin1234"
