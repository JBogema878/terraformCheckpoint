terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "jim-tf-test-bucket"

  tags = {
    Name        = "Jims bucket"
  }
}

# resource "aws_s3_bucket_acl" "example" {
#   bucket = aws_s3_bucket.b.id
#   acl    = "private"
# }