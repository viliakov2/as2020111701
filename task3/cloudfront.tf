resource "aws_cloudfront_distribution" "video" {
  price_class = "PriceClass_100"
  enabled     = true

  origin {
    origin_id   = var.project_name
    origin_path = "/${trimsuffix(var.transcoder_output_prefix, "/")}"
    domain_name = aws_s3_bucket.output.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.video.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.project_name
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "video" {
  comment = "CloudFront origin access identity to get resources from the output S3 bucket"
}
