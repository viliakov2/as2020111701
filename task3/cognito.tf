resource "aws_cognito_identity_pool" "video" {
  identity_pool_name               = var.project_name
  allow_unauthenticated_identities = true
}


resource "aws_iam_role" "unauthenticated" {
  name = "${var.project_name}-cognito-unauthenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.video.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "unauthenticated" {
  name        = "${var.project_name}-cognito-unauthenticated"
  path        = "/"
  description = "The policy for Cognito unauthenticated users"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.input.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.unauthenticated.name
  policy_arn = aws_iam_policy.unauthenticated.arn
}

resource "aws_cognito_identity_pool_roles_attachment" "video" {
  identity_pool_id = aws_cognito_identity_pool.video.id

  roles = {
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}
