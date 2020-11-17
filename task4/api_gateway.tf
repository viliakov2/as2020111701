resource "aws_api_gateway_rest_api" "receive_approval" {
  name = var.project_name
}

resource "aws_api_gateway_resource" "receive_approval" {
  rest_api_id = aws_api_gateway_rest_api.receive_approval.id
  parent_id   = aws_api_gateway_rest_api.receive_approval.root_resource_id
  path_part   = "execution"
}

resource "aws_api_gateway_method" "receive_approval" {
  rest_api_id   = aws_api_gateway_rest_api.receive_approval.id
  resource_id   = aws_api_gateway_resource.receive_approval.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "receive_approval" {
  rest_api_id             = aws_api_gateway_rest_api.receive_approval.id
  resource_id             = aws_api_gateway_resource.receive_approval.id
  http_method             = aws_api_gateway_method.receive_approval.http_method
  integration_http_method = "POST" # GET
  type                    = "AWS"
  uri                     = aws_lambda_function.receive_approval.invoke_arn

  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = <<EOF
{
  "body" : $input.json('$'),
  "headers": {
    #foreach($header in $input.params().header.keySet())
    "$header": "$util.escapeJavaScript($input.params().header.get($header))" #if($foreach.hasNext),#end

    #end
  },
  "method": "$context.httpMethod",
  "params": {
    #foreach($param in $input.params().path.keySet())
    "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end

    #end
  },
  "query": {
    #foreach($queryParam in $input.params().querystring.keySet())
    "$queryParam": "$util.escapeJavaScript($input.params().querystring.get($queryParam))" #if($foreach.hasNext),#end

    #end
  }
}
EOF
  }

  depends_on = [aws_api_gateway_method.receive_approval]
}

resource "aws_api_gateway_integration_response" "receive_approval" {
  rest_api_id = aws_api_gateway_rest_api.receive_approval.id
  resource_id = aws_api_gateway_resource.receive_approval.id
  http_method = aws_api_gateway_method.receive_approval.http_method
  status_code = aws_api_gateway_method_response.receive_approval.status_code
  depends_on = [aws_api_gateway_integration.receive_approval]
}

resource "aws_api_gateway_method_response" "receive_approval" {
  rest_api_id         = aws_api_gateway_rest_api.receive_approval.id
  resource_id         = aws_api_gateway_resource.receive_approval.id
  http_method         = aws_api_gateway_method.receive_approval.http_method
  status_code         = "200"

}

resource "aws_api_gateway_account" "receive_approval" {
  cloudwatch_role_arn = aws_iam_role.receive_approval.arn
}

resource "aws_api_gateway_deployment" "receive_approval" {

  rest_api_id = aws_api_gateway_rest_api.receive_approval.id
  stage_name = "states"

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.receive_approval),
    )))
  }

  depends_on = [aws_api_gateway_method.receive_approval, aws_api_gateway_integration.receive_approval]
}

resource "aws_iam_role" "receive_approval" {
  name = "${var.project_name}-receive_approval"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "receive_approval" {
  name        = "${var.project_name}-apigateway"
  path        = "/"
  description = "The policies for ApiGateway to access needed services"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "receive_approval" {
  role       = aws_iam_role.receive_approval.name
  policy_arn = aws_iam_policy.receive_approval.arn
}

resource "aws_lambda_permission" "invoked_by_api_gateway" {
  statement_id  = "AllowInvokationByAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.receive_approval.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.receive_approval.execution_arn}/*/*/*"
}
