# iam roles
resource "aws_iam_role" "CodePipelineAssumeRole" {
  name = "codepipelineassumerole-frontend"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["codepipeline.amazonaws.com","codebuild.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "CodePipelineRoles" {
  role = aws_iam_role.CodePipelineAssumeRole.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Sid": "CodeCommitPolicy",
      "Effect": "Allow",
      "Action": [
        "codecommit:GitPull"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "*"
      ,
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:List*",
        "s3:Put*",
        "s3:Get*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECRPushPolicy",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "ECRAuthPolicy",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": [
        "*"
      ]
    }, 
    {
      "Sid": "ECS",
      "Effect": "Allow",
      "Action": [
        "ecs:List*",
        "ecs:Describe*"
      ],
      "Resource": [
        "*"
      ]
    }, 
    {
      "Effect": "Allow",
      "Action": [
         "kms:DescribeKey",
         "kms:GenerateDataKey*",
         "kms:Encrypt",
         "kms:ReEncrypt*",
         "kms:Decrypt"
        ],
      "Resource": "*"
    }
  ]
}
POLICY

}
