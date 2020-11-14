
resource "aws_elasticsearch_domain" "review" {
  domain_name           = var.project_name
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type          = var.elasticsearch_instance_type
    instance_count         = var.elasticsearch_instance_count
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = var.elasticsearch_availability_zone_count
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.elasticsearch_instance_volume_size
  }

  vpc_options {
    subnet_ids         = data.terraform_remote_state.task1.outputs.db_subnet_ids
    security_group_ids = [aws_security_group.elasticsearch.id]
  }

  tags       = var.common_tags
  depends_on = [aws_iam_service_linked_role.elasticsearch]
}

resource "aws_iam_service_linked_role" "elasticsearch" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_security_group" "elasticsearch" {
  name   = "${var.project_name}-elasticsearch"
  vpc_id = data.terraform_remote_state.task1.outputs.vpc_id
  tags   = merge({ "Name" : "${var.project_name}-elasticsearch" }, var.common_tags)
}

resource "aws_security_group_rule" "elasticsearch_app_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.task1.outputs.app_security_group_id
  security_group_id        = aws_security_group.elasticsearch.id
}

resource "aws_security_group_rule" "elasticsearch_bastion_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.task1.outputs.bastion_security_group_id
  security_group_id        = aws_security_group.elasticsearch.id
}

resource "aws_iam_policy" "elasticsearch" {
  name        = "${var.project_name}-elasticsearch"
  path        = "/"
  description = "The policy allowing access to Elasticsearch instance"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
              "es:ESHttpGet",
              "es:CreateElasticsearchDomain",
              "es:ListTags",
              "es:DescribeElasticsearchDomainConfig",
              "es:ESHttpDelete",
              "es:GetUpgradeHistory",
              "es:ESCrossClusterGet",
              "es:ESHttpHead",
              "es:DeleteElasticsearchDomain",
              "es:DescribeElasticsearchDomain",
              "es:UpgradeElasticsearchDomain",
              "es:UpdateElasticsearchDomainConfig",
              "es:ESHttpPost",
              "es:GetCompatibleElasticsearchVersions",
              "es:ESHttpPatch",
              "es:CreateOutboundCrossClusterSearchConnection",
              "es:GetUpgradeStatus",
              "es:DescribeElasticsearchDomains",
              "es:ESHttpPut"
          ],
          "Resource": "${aws_elasticsearch_domain.review.arn}"
      },
      {
          "Sid": "VisualEditor1",
          "Effect": "Allow",
          "Action": [
              "es:DescribeReservedElasticsearchInstanceOfferings",
              "es:ListElasticsearchInstanceTypeDetails",
              "es:CreateElasticsearchServiceRole",
              "es:RejectInboundCrossClusterSearchConnection",
              "es:PurchaseReservedElasticsearchInstanceOffering",
              "es:DeleteElasticsearchServiceRole",
              "es:AcceptInboundCrossClusterSearchConnection",
              "es:DescribeInboundCrossClusterSearchConnections",
              "es:DescribeReservedElasticsearchInstances",
              "es:ListDomainNames",
              "es:DeleteInboundCrossClusterSearchConnection",
              "es:ListElasticsearchInstanceTypes",
              "es:DescribeOutboundCrossClusterSearchConnections",
              "es:ListElasticsearchVersions",
              "es:DescribeElasticsearchInstanceTypeLimits",
              "es:DeleteOutboundCrossClusterSearchConnection"
          ],
          "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "elasticsearch" {
  role       = data.terraform_remote_state.task1.outputs.app_iam_role
  policy_arn = aws_iam_policy.elasticsearch.arn
}
