aws_region   = "us-east-1"
project_name = "assessment"
common_tags = {
  CostCenter  = 1981
  Owner       = "Me"
  Application = "Webshop"
  Environment = "test"
}

dynamodb_reviews_write_capacity = 5
dynamodb_reviews_read_capacity  = 5

elasticsearch_instance_type           = "t2.small.elasticsearch"
elasticsearch_version                 = "7.8"
elasticsearch_instance_count          = 2
elasticsearch_availability_zone_count = 2
elasticsearch_instance_volume_size    = 20
