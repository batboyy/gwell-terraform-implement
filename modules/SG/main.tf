terraform {
  backend "s3" {}
  required_version = "0.13.2"
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
  version                 = ">= 2.28.1"
}

variable "name" {
  description = "The name of the security groups serves as a prefix, e.g stack"
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "environment" {
  description = "The environment, used for tagging, e.g prod"
}

variable "region" {
  description = "AWS Region, e.g us-west-2"
  type        = "string"
}


resource "aws_security_group" "test" {
  name        = "${format("%s-%s-monitoring-client", var.name, var.environment)}"
  description = "Security group for monitoring clients, grants access to the associated monitoring endpoints"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name        = "${format("%s monitoring-client", var.name)}"
    Environment = "${var.environment}"
    Function    = "${var.name}"
    Stage       = "${var.environment}"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


output "monitoring_client" {
  value = "${aws_security_group.test.id}"
}