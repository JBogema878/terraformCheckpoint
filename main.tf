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

//create a bucket

resource "aws_s3_bucket" "b" {
  bucket = "jim-tf-test-bucket"

  tags = {
    Name = "Jims bucket"
  }
}

//adding an object to that bucket, which in this case is my jar file for gautos spring boot app

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.b.id
  key    = "g-hello-0.0.1-SNAPSHOT.jar"
  source = "./target/g-hello-0.0.1-SNAPSHOT.jar"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("./target/g-hello-0.0.1-SNAPSHOT.jar")
}

//security group

resource "aws_security_group" "allow" {
  name        = "allow"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "jim_group1"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jim_group2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow"
  }
}

resource "aws_iam_role_policy" "jim_role_policy" {
  role = aws_iam_role.jim_iam_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : [
          "arn:aws:s3:::jim-tf-test-bucket/g-hello-0.0.1-SNAPSHOT.jar",
          "arn:aws:s3:::jim-tf-test-bucket"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "jim_iam_role" {

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "test_profile1" {
  name = "test_profile1"
  role = aws_iam_role.jim_iam_role.name
}

resource "aws_instance" "jim2-ec2" {
  ami           = "ami-0b0dcb5067f052a63" # us-east-1
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow.name]
  key_name = "JB-key-pair"
  iam_instance_profile = "test_profile1"
  tags = {
    Name = "jim2-ec2"
  }
  user_data_replace_on_change = true
  user_data = <<EOF
#! /bin/bash
yum update -y
yum install -y java-11-amazon-corretto-headless
aws s3api get-object --bucket "jim-tf-test-bucket" --key "g-hello-0.0.1-SNAPSHOT.jar" "g-hello-0.0.1-SNAPSHOT.jar"
java -jar g-hello-0.0.1-SNAPSHOT.jar
EOF


}

