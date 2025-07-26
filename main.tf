provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket to store the Lambda zip
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "my-unique-lambda-bucket-123456" # Replace with a globally unique name
  force_destroy = true
}

# Upload the ZIP file to S3
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "function.zip"
  source = "function.zip"
  etag   = filemd5("function.zip")
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach basic execution role to Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Archive the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "function.zip"
}

# Create the Lambda function from S3
resource "aws_lambda_function" "hello_lambda" {
  function_name = "hello_lambda"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.lambda_zip.key
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn
  depends_on    = [aws_s3_object.lambda_zip]
}
