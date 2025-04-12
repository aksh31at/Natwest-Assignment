provider "aws" {
  region = "us-east-1"  # or whatever new region you chose
}

resource "aws_instance" "example" {
  ami           = "ami-0c40f67d933cfc99d"  # your new AMI ID in the new region
  instance_type = "t2.micro"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
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
  role          = aws_iam_role.lambda_exec_role.name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename         = "akshat-lambda-739ab9b7-191b-4013-834e-f077930b3ba2.zip"
  source_code_hash = filebase64sha256("akshat-lambda-739ab9b7-191b-4013-834e-f077930b3ba2.zip")
}
