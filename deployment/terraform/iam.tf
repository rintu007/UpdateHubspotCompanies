resource "aws_iam_role" "lambda_download" {
  name                = "lambda_downloadCustomers"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "read_write_services" {
  name    = "DynamoDBReadWriteServicesTable"
  role    = aws_iam_role.lambda_download.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/services"
    }
  ]
}
EOF
}