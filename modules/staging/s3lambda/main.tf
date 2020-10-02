terraform {
  backend "s3" {}
  required_version = "0.13.4"
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
  version                 = ">= 2.28.1"
}


variable "region" {
  description = "AWS Region, e.g us-west-2"
  default = "us-east-1"
}


variable "bucket_name" {
  description = "Bucket Name"
  default = "worldwarz-season1"
  
}

variable "bucket_name_event" {
  description = "Bucket Name"
  default = "worldwarz-season23"
  
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}



resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "Gwell_python_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.6"

  environment {
    variables = {
      foo = "bar"
    }
  }
}



resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name_event
  acl    = "public-read"  
  versioning {
    enabled = true
  }

}



resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
bucket = "${aws_s3_bucket.b.id}"
lambda_function {
lambda_function_arn = "${aws_lambda_function.test_lambda.arn}"
events              = ["s3:ObjectCreated:*"]
filter_prefix       = "file-prefix"
filter_suffix       = "file-extension"
}
}

resource "aws_lambda_permission" "test" {
statement_id  = "AllowS3Invoke"
action        = "lambda:InvokeFunction"
function_name = "${aws_lambda_function.test_lambda.function_name}"
principal = "s3.amazonaws.com"
source_arn = "arn:aws:s3:::${aws_s3_bucket.b.id}"
}
