resource "aws_sfn_state_machine" "video_processing" {
  name     = "video_processing"
  role_arn = aws_iam_role.sfn.arn

  definition = <<EOF
{
  "StartAt": "Request Approval",
  "States": {
    "Request Approval": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
        "Parameters": {
          "FunctionName": "${aws_lambda_function.request_approval.arn}",
          "Payload": {
            "ExecutionContext.$": "$$",
            "APIGatewayEndpoint": "https://${aws_api_gateway_rest_api.receive_approval.id}.execute-api.${var.aws_region}.amazonaws.com/states",
            "Input.$": "$",
            "TaskToken.$": "$$.Task.Token"
          }
        },
        "Next": "Manual Approval Choice State"
    },
    "Manual Approval Choice State": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Status",
          "StringEquals": "Approved",
          "Next": "Approved State"
        },
        {
          "Variable": "$.Status",
          "StringEquals": "Rejected",
          "Next": "Rejected State"
        }
      ]
    },
    "Approved State": {
      "Type": "Pass",
      "Next": "Run Transcoder Job"
    },
    "Run Transcoder Job": {
        "Type": "Task",
        "Resource": "arn:aws:states:::lambda:invoke",
        "Parameters": {
          "FunctionName": "${aws_lambda_function.trigger_transcoder.arn}",
          "Payload": {
            "ExecutionContext.$": "$$"
          }
        },
        "End": true
    },
    "Rejected State": {
      "Type": "Pass",
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "sfn" {
  name = "${var.project_name}-sfn"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sfn" {
  name        = "${var.project_name}-sfn"
  path        = "/"
  description = "The policies for Step functions to access needed services"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "${aws_lambda_function.trigger_transcoder.arn}",
                "${aws_lambda_function.request_approval.arn}"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sfn" {
  role       = aws_iam_role.sfn.name
  policy_arn = aws_iam_policy.sfn.arn
}
