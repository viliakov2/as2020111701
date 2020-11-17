resource "aws_lambda_function" "trigger_transcoder" {
  function_name    = "${var.project_name}-convert-video"
  filename         = "${path.module}/lambda/trigger_transcoder.zip"
  role             = aws_iam_role.lambda.arn
  handler          = "trigger_transcoder.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/trigger_transcoder.zip")


  runtime = "python3.8"

  environment {
    variables = {
      PIPELINE_ID   = aws_elastictranscoder_pipeline.convert_video.id
      PRESET_ID     = var.transcoder_preset_id
      OUTPUT_PREFIX = var.transcoder_output_prefix
    }
  }
}

resource "aws_lambda_permission" "invoked_by_s3_event" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_transcoder.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input.arn
}

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name        = "${var.project_name}-lambda"
  path        = "/"
  description = "The Lambda policy to access Transcoder and S3"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "elastictranscoder:*"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
