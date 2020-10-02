terraform {
  backend "s3" {}
  required_version = "0.13.2"
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
  version                 = ">= 2.28.1"
}


variable "region" {
  description = "AWS Region, e.g us-west-2"
  
}


variable "bucket_name" {
  description = "Bucket Name"
  
}

resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  

website {
     index_document = "index.html"
     error_document = "error.html"

   }

  
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

  policy = <<POLICY
{
  "Id": "Policy1599755120372",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1599755117737",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.b.id}/*",
      "Principal": "*"
    }
  ]
}
POLICY
}


locals {
  s3_origin_id = "myS3Origin"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.b.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  // logging_config {
  //   include_cookies = false
  //   bucket          = "mylogs.s3.amazonaws.com"
  //   prefix          = "myprefix"
  // }

  // aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    // min_ttl                = 0
    // default_ttl            = 3600
    // max_ttl                = 86400

     
  }
  

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id
    // cache_policy           = "Managed-CachingDisabled"
    //origin_request_policy = "Managed-AllViewer" 

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

   
    viewer_protocol_policy = "redirect-to-https"
    
  }

  # Cache behavior with precedence 1
  // ordered_cache_behavior {
  //   path_pattern     = "/content/*"
  //   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  //   cached_methods   = ["GET", "HEAD"]
  //   target_origin_id = local.s3_origin_id

  //   forwarded_values {
  //     query_string = false

  //     cookies {
  //       forward = "none"
  //     }
  //   }

  //   min_ttl                = 0
  //   default_ttl            = 3600
  //   max_ttl                = 86400
  //   compress               = true
  //   viewer_protocol_policy = "redirect-to-https"
  // }

  price_class = "PriceClass_All" 

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

// https://notes.webutvikling.org/s3-bucket-cloudfront-using-terraform/