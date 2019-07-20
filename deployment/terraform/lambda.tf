resource "aws_lambda_function" "download_customers" {
  filename          = "../packages/downloadCustomers/function.zip"
  source_code_hash  = filebase64sha256("../packages/downloadCustomers/function.zip")
  handler           = "main.lambda_handler"

  function_name     = local.lambda_download_customers_name
  role              = aws_iam_role.lambda_download.arn
  
  runtime           = "python3.7"
  timeout           = 10

  environment {
    variables = {
      FTP_USERNAME  = var.ftp_username
      FTP_PASSWORD  = var.ftp_password
      FTP_URL       = var.ftp_url
      LOGLEVEL      = var.log_level
    }
  }
}

resource "aws_cloudwatch_log_group" "download_customers" {
  name = "/aws/lambda/${local.lambda_download_customers_name}"
}

resource "aws_cloudwatch_event_rule" "every_morning" {
  name                = "every-morning-at-8am"
  description         = "Triggers every day at 8am"
  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "check_every_morning" {
  rule      = aws_cloudwatch_event_rule.every_morning.name
  target_id = "check_daisy_server"
  arn       = aws_lambda_function.download_customers.arn
}

resource "aws_lambda_permission" "allow_execution_from_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.download_customers.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_morning.arn
}