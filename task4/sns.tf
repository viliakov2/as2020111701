resource "aws_sns_topic" "request_for_approval" {
  name = "${var.project_name}-request_for_approval"
  tags = var.common_tags
}
