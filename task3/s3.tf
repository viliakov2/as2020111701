resource "aws_s3_bucket" "input" {
  bucket_prefix = "${var.project_name}-input"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE", "HEAD"]
    allowed_origins = [var.frontent_application_dns_name]
    expose_headers  = ["ETag"]
    max_age_seconds = 0
  }

  tags = var.common_tags

}

resource "aws_s3_bucket_notification" "invoke_lambda" {
  bucket = aws_s3_bucket.input.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger_transcoder.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.invoked_by_s3_event]
}


resource "aws_s3_bucket" "output" {
  bucket_prefix = "${var.project_name}-output"
  tags          = var.common_tags
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.output.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "CloudFront_OAI_access",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.video.id}"
      },
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.output.arn}/*"
    }
  ]
}
EOF

}
