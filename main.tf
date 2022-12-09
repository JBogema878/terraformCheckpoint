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
    Name        = "Jims bucket"
  }
}

//adding an object to that bucket, which in this case is my jar file for gautos spring boot app

resource "aws_s3_object" "object" {
  bucket = "jim-tf-test-bucket"
  key    = "guatos_jarFile"
  source = "./target/g-autos-0.0.1-SNAPSHOT.jar"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("./target/g-autos-0.0.1-SNAPSHOT.jar")
}
