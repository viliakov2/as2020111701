output "elasticsearch_endpoint" {
  description = "The Elasticsearch endpoint"
  value       = aws_elasticsearch_domain.review.endpoint
}

output "dynamodb_table_arn" {
  description = "The DynamoDB ARN table"
  value       = aws_dynamodb_table.reviews.arn
}
