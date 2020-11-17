resource "aws_dynamodb_table" "reviews" {
  name           = "${var.project_name}-reviews"
  billing_mode   = "PROVISIONED"
  write_capacity = var.dynamodb_reviews_write_capacity
  read_capacity  = var.dynamodb_reviews_read_capacity
  hash_key       = "ID"
  range_key      = "productID"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "productID"
    type = "S"
  }

  attribute {
    name = "userID"
    type = "S"
  }

  attribute {
    name = "productScore"
    type = "N"
  }

  global_secondary_index {
    name           = "${var.project_name}-productScore"
    hash_key       = "productID"
    range_key      = "productScore"
    write_capacity = var.dynamodb_reviews_write_capacity
    read_capacity  = var.dynamodb_reviews_read_capacity

    projection_type    = "INCLUDE"
    non_key_attributes = ["userId", "created", "ID"]
  }

  local_secondary_index {
    name            = "${var.project_name}-users"
    range_key       = "userID"
    projection_type = "ALL"
  }

  tags = var.common_tags
}

resource "aws_iam_policy" "dynomodb" {
  name        = "${var.project_name}-dynomodb"
  path        = "/"
  description = "The policy allowing access to dynomodb instance"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
            "dynamodb:DeleteItem",
            "dynamodb:DescribeContributorInsights",
            "dynamodb:RestoreTableToPointInTime",
            "dynamodb:ListTagsOfResource",
            "dynamodb:CreateTableReplica",
            "dynamodb:UpdateContributorInsights",
            "dynamodb:UpdateGlobalTable",
            "dynamodb:CreateBackup",
            "dynamodb:DeleteTable",
            "dynamodb:UpdateTableReplicaAutoScaling",
            "dynamodb:UpdateContinuousBackups",
            "dynamodb:DescribeTable",
            "dynamodb:GetItem",
            "dynamodb:DescribeContinuousBackups",
            "dynamodb:DescribeExport",
            "dynamodb:CreateGlobalTable",
            "dynamodb:BatchGetItem",
            "dynamodb:UpdateTimeToLive",
            "dynamodb:BatchWriteItem",
            "dynamodb:ConditionCheckItem",
            "dynamodb:PutItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:DescribeStream",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteTableReplica",
            "dynamodb:DescribeTimeToLive",
            "dynamodb:CreateTable",
            "dynamodb:UpdateGlobalTableSettings",
            "dynamodb:DescribeGlobalTableSettings",
            "dynamodb:GetShardIterator",
            "dynamodb:DescribeGlobalTable",
            "dynamodb:RestoreTableFromBackup",
            "dynamodb:ExportTableToPointInTime",
            "dynamodb:DescribeBackup",
            "dynamodb:DeleteBackup",
            "dynamodb:UpdateTable",
            "dynamodb:GetRecords",
            "dynamodb:DescribeTableReplicaAutoScaling"
        ],
        "Resource": "${aws_dynamodb_table.reviews.arn}"
    },
    {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
            "dynamodb:ListContributorInsights",
            "dynamodb:DescribeReservedCapacityOfferings",
            "dynamodb:ListGlobalTables",
            "dynamodb:ListTables",
            "dynamodb:DescribeReservedCapacity",
            "dynamodb:ListBackups",
            "dynamodb:PurchaseReservedCapacityOfferings",
            "dynamodb:DescribeLimits",
            "dynamodb:ListExports",
            "dynamodb:ListStreams"
        ],
        "Resource": "*"
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = data.terraform_remote_state.task1.outputs.app_iam_role
  policy_arn = aws_iam_policy.dynomodb.arn
}

resource "aws_vpc_endpoint" "private-dynamodb" {
  vpc_id          = data.terraform_remote_state.task1.outputs.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = data.terraform_remote_state.task1.outputs.app_route_table_ids
}
