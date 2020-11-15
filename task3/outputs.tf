output "cf_dns_name" {
  description = "The dns name of CloudFront distribution"
  value       = aws_cloudfront_distribution.video.domain_name
}

output "s3_input_bucket" {
  description = "The S3 bucket to upload customer videos"
  value       = aws_s3_bucket.input.id
}

output "s3_output_bucket" {
  description = "The S3 bucket to store thumbnails and processed videos"
  value       = aws_s3_bucket.output.id
}

output "cognito_identity_pool" {
  description = "The Cognito Identity Pool to retrieve AWS Credentials"
  value       = aws_cognito_identity_pool.video.id
}

output "sns_topic_arn" {
  description = "The SNS topic ARB to get Job statuses"
  value       = aws_sns_topic.transcoder.arn
}
