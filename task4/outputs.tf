output "s3_input_bucket" {
  description = "The S3 bucket to upload customer videos"
  value       = aws_s3_bucket.input.id
}

output "s3_output_bucket" {
  description = "The S3 bucket to store thumbnails and processed videos"
  value       = aws_s3_bucket.output.id
}

output "sns_request_for_approval_arn" {
  description = "The SNS topic ARB to get Job statuses"
  value       = aws_sns_topic.request_for_approval.arn
}
