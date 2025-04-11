provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0274f4b62b6ae3bd5"  # Amazon Linux 2
  instance_type = "t3.micro"
}
