resource "aws_iam_role" "keep-instances-running" {
  name               = "keep-instances-running"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "keepInstancesRunning"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "keep-instances-running" {
  name   = "keep-instances-running"
  role   = aws_iam_role.keep-instances-running.id
  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Effect":"Allow",
            "Action":[
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource":"arn:aws:logs:*:*:*"
        },
        {
            "Effect":"Allow",
            "Action":[
                "ec2:Start*",
                "ec2:DescribeInstance*"
            ],
            "Resource":"*"
        },
        {
            "Effect":"Allow",
            "Action":[
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource":[
                "${aws_secretsmanager_secret.email.arn}",
                "${aws_secretsmanager_secret_version.email.arn}"
            ]
        }
    ]
}
EOF

}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/source/"
  output_path = "${path.module}/keep-instances-running.zip"
}

locals {
  function_name = "keep-instances-running"
}

resource "aws_lambda_function" "keep-instances-running" {
  depends_on       = [data.archive_file.lambda_zip]
  filename         = "${path.module}/keep-instances-running.zip"
  timeout          = 60
  function_name    = local.function_name
  role             = aws_iam_role.keep-instances-running.arn
  handler          = "keep-instances-running.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  environment {
    variables = {
      secrets_manager_email_creds_arn = aws_secretsmanager_secret.email.arn
      # extended_recipients = "wayne@theworkmans.us"
      cloudwatch_log_group_name  = aws_cloudwatch_log_group.keep-instances-running.name
      cloudwatch_log_stream_name = local.function_name
    }
  }
}

resource "aws_cloudwatch_log_group" "keep-instances-running" {
  name = "/aws/lambda/${local.function_name}"
}

