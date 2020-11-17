resource "aws_s3_bucket" "input" {
  bucket_prefix = "${var.project_name}-input"

  tags = var.common_tags
}

resource "aws_s3_bucket_notification" "invoke_lambda" {
  bucket = aws_s3_bucket.input.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.run_step_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.invoked_by_s3_event]
}

resource "aws_lambda_permission" "invoked_by_s3_event" {
  statement_id  = "AllowExecutionFromS3BucketTask4"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.run_step_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input.arn
}

resource "aws_s3_bucket" "output" {
  bucket_prefix = "${var.project_name}-output"
  tags          = var.common_tags
}
