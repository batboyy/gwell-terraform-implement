provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  version                 = ">= 2.28.1"
}

variable "cognito_authentication_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Amazon Cognito authentication with Kibana"
}

variable "elasticsearch_domain_name" {
  type        = string
  default     = "test-elasticsearch"
  description = "The name of the subdomain for Elasticsearch in the DNS zone (_e.g._ `elasticsearch`, `ui`, `ui-es`, `search-ui`)"
}


resource "aws_iam_role_policy" "AmazonESCognitoAccess" {
  name = "amazonESCognitoAccess"
  role = aws_iam_role.iam_for_cognito.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
      "Effect": "Allow",
        "Action": [
          "cognito-idp:DescribeUserPool",
          "cognito-idp:CreateUserPoolClient",
          "cognito-idp:DeleteUserPoolClient",
                "cognito-idp:DescribeUserPoolClient",
                "cognito-idp:AdminInitiateAuth",
                "cognito-idp:AdminUserGlobalSignOut",
                "cognito-idp:ListUserPoolClients",
                "cognito-identity:DescribeIdentityPool",
                "cognito-identity:UpdateIdentityPool",
                "cognito-identity:SetIdentityPoolRoles",
                "cognito-identity:GetIdentityPoolRoles"
        ],
        
        "Resource": "*"
      },

      {
          "Sid": "es",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "cognito-identity.amazonaws.com"
                }
            }
        }


    ]
  }
  EOF
}



resource "aws_iam_role" "iam_for_cognito" {
  name = "cognitoaccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}




 resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.elasticsearch_domain_name
  elasticsearch_version = "7.7"

  cluster_config {
    instance_count = 2

    instance_type = "t2.medium.elasticsearch"

    zone_awareness_enabled = true
    
    zone_awareness_config {
        availability_zone_count = 2
      }
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  vpc_options {
      subnet_ids = ["subnet-0b83292a","subnet-933b97f5"]
      security_group_ids = [
          "sg-d7cfd1eb"
      ]
  }

    ebs_options {
    ebs_enabled =  "10" > 0 ? true : false
    volume_size = "10"
    volume_type = "gp2"
   
  }


  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::514973783741:role/Cognito_sunitAuth_Role"
      },
      "Action": ["es:*","iam:PassRole"],
      "Resource": "arn:aws:es:us-east-1:514973783741:domain/var.elasticsearch_domain_name/*"
    }
  ]
}
  CONFIG


 domain_endpoint_options {
    enforce_https       = "true"
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
    
  }

 cognito_options {
    
    
      enabled          = "true"
      user_pool_id     = "us-east-1_itea7uNA2"
      identity_pool_id = "us-east-1:5d7de927-e2d6-41cb-88aa-01c4d9e1b0f2"
      role_arn         = aws_iam_role.iam_for_cognito.arn
    
  }


  tags = {
    Domain = "TestDomain"
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}