terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

#—— VARIABLES ——————————————————————————————————————————————
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "Globally-unique name for the S3 static website bucket"
  type        = string
  # Replace this with YOUR unique name before applying
  default     = "my-unique-static-site-12345"
}

variable "my_ip" {
  description = "Your public IP (for SSH access). E.g. 1.2.3.4/32"
  type        = string
  # Replace with your IP/CIDR
  default     = "0.0.0.0/0"
}

#—— DATA: Latest Amazon Linux 2 AMI —————————————————————————
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#—— S3: Static Website Bucket —————————————————————————————
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

#—— NETWORK: Default VPC & Security Group —————————————————————
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH from my IP and HTTP from anywhere"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#—— EC2: Example Instance —————————————————————————————————
resource "aws_instance" "example" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "example-instance"
  }
}

#—— IAM: Role for Lambda ————————————————————————————————
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_akshat"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#—— LAMBDA: Function Resource —————————————————————————————
resource "aws_lambda_function" "my_lambda" {
  function_name    = "my_lambda_function_akshat"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

#—— OUTPUTS ———————————————————————————————————————————————
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "s3_website_endpoint" {
  description = "S3 static website endpoint"
  value       = aws_s3_bucket.static_site.website_endpoint
}

output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.my_lambda.function_name
}
