variable "aws_region" {
  type        = string
  description = "The default AWS region"
}

variable "project_name" {
  type        = string
  description = "The project name. It is used to name resources"
}

variable "common_tags" {
  type        = map
  description = "The common tags assigned to the resources"
  default     = {}
}

variable "dynamodb_reviews_read_capacity" {
  type        = number
  description = "DynamoDB table read capacity"
}

variable "dynamodb_reviews_write_capacity" {
  type        = number
  description = "DynamoDB table write capacity"
}

variable "elasticsearch_instance_type" {
  type        = string
  description = "The Elasticsearch instance type"
}

variable "elasticsearch_version" {
  type        = string
  description = "The Elasticsearch engine version"
}

variable "elasticsearch_instance_count" {
  type        = number
  description = "The number of Elasticsearh nodes"
}

variable "elasticsearch_availability_zone_count" {
  type        = number
  description = "The number of Availability zones to spread node across"
}

variable "elasticsearch_instance_volume_size" {
  type        = number
  description = "The size of EBS volume attached to Elasticsearch node"
}
