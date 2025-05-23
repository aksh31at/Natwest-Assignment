provider "aws" {
  region = "eu-north-1"
}

# EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0274f4b62b6ae3bd5"  # Amazon Linux 2
  instance_type = "t3.micro"
  tags = {
    Name = "MyExampleInstance"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach basic logging policy to the role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function (upload zip separately to repo or S3)
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "akshat-lambda-739ab9b7-191b-4013-834e-f077930b3ba2.zip"
  source_code_hash = filebase64sha256("akshat-lambda-739ab9b7-191b-4013-834e-f077930b3ba2.zip")
}
