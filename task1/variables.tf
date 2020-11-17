variable "aws_region" {
  type        = string
  description = "The default AWS region"
}

variable "project_name" {
  type        = string
  description = "The project name. It is used to name resources"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "common_tags" {
  type        = map
  description = "The common tags assigned to the resources"
  default     = {}
}

variable "vpc_front_subnets" {
  type        = list
  description = "The list containing CIDRs of public networks"
}

variable "vpc_app_subnets" {
  type        = list
  description = "The list containing CIDRs of application networks"
}

variable "vpc_db_subnets" {
  type        = list
  description = "The list containing CIDRs of database networks"
}

variable "ec2_key_name" {
  type        = string
  description = "The name of the ssh key-pair for application and bastion hosts"
}

variable "ec2_public_key" {
  type        = string
  description = "The public part of the ssh key-pair"
}

variable "app_asg_min_size" {
  type        = number
  description = "The minimum number of instances for the application ASG"
}

variable "app_asg_max_size" {
  type        = number
  description = "The maximum number of instances for the application ASG"
}

variable "app_desired_capacity" {
  type        = number
  description = "The desired number of instances for the application ASG"
}

variable "app_instance_type" {
  type        = string
  description = "The instance type of the application instances"
}

variable "bastion_asg_min_size" {
  type        = number
  description = "The minimum number of instances for the bastion ASG"
}

variable "bastion_asg_max_size" {
  type        = number
  description = "The maximum number of instances for the bastion ASG"
}

variable "bastion_desired_capacity" {
  type        = number
  description = "The desired number of instances for the bastion ASG"
}

variable "bastion_instance_type" {
  type        = string
  description = "The instance type of the bastion host"
}

variable "rds_allocated_storage" {
  type        = number
  description = "The allocated storage in gibibytes"
}

variable "rds_engine" {
  type        = string
  description = "The database engine"
}

variable "rds_instance_class" {
  type        = string
  description = "The instance type of the RDS instance"
}

variable "magento_db_name" {
  type        = string
  description = "The name of the Magento database"
}

variable "magento_db_username" {
  type        = string
  description = "The username for Magento database"
}

variable "magento_db_password" {
  type        = string
  description = "The password for Magento database"
}

variable "rds_engine_version" {
  type        = string
  description = "The RDS engine version"
}

variable "rds_multi_az" {
  type        = string
  description = "Whether MultiAZ should be turn on for the RDS"
}

variable "cache_engine" {
  type        = string
  description = "The Cache engine"
}

variable "cache_engine_version" {
  type        = string
  description = "The Cache engine version"
}

variable "cache_instance_type" {
  type        = string
  description = "The instance type of the Cache instances"
}

variable "cache_parameter_group_name" {
  type        = string
  description = "The Cache parameter group name"
}

variable "composer_username" {
  type        = string
  description = "The credentials to download Magento package"
}
variable "composer_password" {
  type        = string
  description = "The credentials to download Magento package"
}

variable "magento_admin_user" {
  type        = string
  description = "The Magento admin credentials"
}

variable "magento_admin_password" {
  type        = string
  description = "The Magento admin credentials"
}
