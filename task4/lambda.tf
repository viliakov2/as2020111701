
resource "aws_lambda_function" "run_step_function" {
  function_name    = "${var.project_name}-run-step-function"
  filename         = "${path.module}/lambda/run_step_function.zip"
  role             = aws_iam_role.lambda.arn
  handler          = "run_step_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/run_step_function.zip")
  runtime          = "python3.8"

  environment {
    variables = {
      STEP_FUNCTION_ARN = aws_sfn_state_machine.video_processing.arn
    }
  }
}

resource "aws_lambda_function" "receive_approval" {
  function_name    = "${var.project_name}-receive-approval"
  filename         = "${path.module}/lambda/receive_approval.zip"
  role             = aws_iam_role.lambda.arn
  handler          = "receive_approval.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/receive_approval.zip")
  runtime          = "python3.8"

  environment {
    variables = {
      STEP_FUNCTION_ARN = aws_sfn_state_machine.video_processing.arn
    }
  }
}

resource "aws_lambda_function" "request_approval" {
  function_name    = "${var.project_name}-request-approval"
  filename         = "${path.module}/lambda/request_approval.zip"
  role             = aws_iam_role.lambda.arn
  handler          = "request_approval.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/request_approval.zip")
  runtime          = "python3.8"

  environment {
    variables = {
      SNS_APPROVAL_ARN = aws_sns_topic.request_for_approval.arn
    }
  }
}

resource "aws_lambda_function" "trigger_transcoder" {
  function_name    = "${var.project_name}-trigger-transcoder"
  filename         = "${path.module}/lambda/trigger_transcoder.zip"
  role             = aws_iam_role.lambda.arn
  handler          = "trigger_transcoder.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/trigger_transcoder.zip")
  runtime          = "python3.8"

  environment {
    variables = {
      PIPELINE_ID   = aws_elastictranscoder_pipeline.convert_video.id
      PRESET_ID     = var.transcoder_preset_id
      OUTPUT_PREFIX = var.transcoder_output_prefix
    }
  }
}

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-task4"

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
  name        = "${var.project_name}-lambda-task4"
  path        = "/"
  description = "The policies for Lambda to access needed services"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:*",
          "elastictranscoder:*",
          "states:*",
          "sns:*"
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
