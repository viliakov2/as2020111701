resource "aws_ssm_parameter" "elasticsearch_endpoint" {
  name  = "/magento/elasticsearch_endpoint"
  type  = "String"
  value = aws_elasticsearch_domain.review.endpoint
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "dynamodb_table" {
  name  = "/magento/dynamodb_table"
  type  = "String"
  value = aws_dynamodb_table.reviews.arn
  tags  = var.common_tags
}
