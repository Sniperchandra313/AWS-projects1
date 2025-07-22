provider "aws" {
  region = "us-east-1"  # Change region as needed
  access_key = "AKIA4LQJRLXSVKKDZLIJ"
  secret_key = "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"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "function.zip"
}

resource "aws_lambda_function" "hello_lambda" {
  function_name = "hello_lambda"
  filename      = data.archive_file.lambda_zip.output_path
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  depends_on   = [data.archive_file.lambda_zip]
}
