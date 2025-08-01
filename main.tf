data "aws_caller_identity" "current" {}
output "whoami" {
 value = data.aws_caller_identity.current
}
terraform { 
  cloud { 
    
    organization = "Sniperchandra313" 

    workspaces { 
      name = "TF-workspace1" 
    } 
  } 
}
provider "aws" {
  region = "us-east-1"  # Change region as needed
  assume_role {
   role_arn     = "arn:aws:iam::849349795301:role/tf-cloud-role1"  # From Step 1
 }
 
}

resource "aws_iam_role" "lambda_exec_role"{
  name = "lambda_exec_role1"

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
