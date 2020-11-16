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

variable "frontend_application_dns_name" {
  type        = string
  description = "The frontend application dns name. It is used as an origin for S3 bucket CORS rule"
}

variable "transcoder_preset_id" {
  type        = string
  description = "The AWS Transcoder Preset Id to convert incoming videos"
}

variable "transcoder_output_prefix" {
  type        = string
  description = "The prefix for S3 objects containinf processed videos and thumbnails. It is also used as a CloudFront origin_path, so must end with '/'"
}
