resource "aws_elastictranscoder_pipeline" "convert_video" {
  input_bucket = aws_s3_bucket.input.bucket
  name         = var.project_name
  role         = aws_iam_role.transcoder.arn

  content_config {
    bucket        = aws_s3_bucket.output.bucket
    storage_class = "Standard"
  }

  thumbnail_config {
    bucket        = aws_s3_bucket.output.bucket
    storage_class = "ReducedRedundancy"
  }

  notifications {
    completed = aws_sns_topic.transcoder.arn
    error     = aws_sns_topic.transcoder.arn
  }

}


resource "aws_iam_role" "transcoder" {
  name = "${var.project_name}-transcoder"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "elastictranscoder.amazonaws.com"
      }
    }
  ]
}
EOF
  tags               = var.common_tags
}

resource "aws_iam_policy" "transcoder" {
  name        = "${var.project_name}-transcoder"
  path        = "/"
  description = "The transcoder policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:Put*",
              "s3:*MultipartUpload*",
              "s3:Get*"
            ],
            "Resource": [
              "${aws_s3_bucket.input.arn}/*",
              "${aws_s3_bucket.output.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "${aws_sns_topic.transcoder.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "transcoder" {
  role       = aws_iam_role.transcoder.name
  policy_arn = aws_iam_policy.transcoder.arn
}

resource "aws_sns_topic" "transcoder" {
  name = "${var.project_name}-transcoder-job-statuses"
  tags = var.common_tags
}
