// variable"github_oauth_token"{
//     description = "This is the OAuth token of Github"
// }

// variable"vpc_id"{
//     description = "This consists VPC id"
// }

// variable"subnets"{
//     description = "This consist VPC Subnet id"
// }

// variable"security_group_id"{
//     description = "This is security group id od default vpc"
// }

// provider "aws" {
//   region                  = "us-east-1"
//   shared_credentials_file = "~/.aws/credentials"
//   version                 = ">= 2.28.1"
// }

// variable"s3_folder"{
//      description = "This is folder/key created under bucket"
//      default  = "test/"
//  }


// resource "aws_s3_bucket" "gwellBucket" {
//   bucket = "gwell-pawan-sunit-123"
//   acl    = "private"

  
// }


// resource "aws_s3_bucket_object" "apples" {
//   bucket       = "${aws_s3_bucket.gwellBucket.id}"
//   key          = "test/"
//   content_type = "application/x-directory"
// }


#GIT CRED
resource "aws_codebuild_source_credential" "GitCred" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "39ff3df061c5e5a5ac0846dc1da0f2145f815189"
}

#CodeBuild
resource "aws_codebuild_project" "CodeBuildProject" {
  name          = "gWellQA-frontend"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.CodePipelineAssumeRole.arn

  artifacts {
    type = "NO_ARTIFACTS"
    //location = "gwell-pawan-sunit-123"
  }

#   cache {
#     type     = "S3"
#     location = aws_s3_bucket.example.bucket
#   }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # environment_variable {
    #   name  = "SOME_KEY1"
    #   value = "SOME_VALUE1"
    # }

    # environment_variable {
    #   name  = "SOME_KEY2"
    #   value = "SOME_VALUE2"
    #   type  = "PARAMETER_STORE"
    # }
  }


 logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
  
    }
 }

   source {
    type       = "NO_SOURCE"
    buildspec = file("buildspec.yml")

    // location   = "gwell-pawan-sunit-123/test" 
    // auth {
    //   type     = "OAUTH"
    //   resource = aws_codebuild_source_credential.GitCred.arn
    // }
    //  git_submodules_config {
    //   fetch_submodules = true
    // }
  }



  // source_version = "master"

  // vpc_config {
  //   vpc_id = "vpc-a801f9d5"

  //   subnets = ["subnet-0305640d"]

  //   security_group_ids = ["sg-d7cfd1eb"]
  // }

  tags = {
    Environment = "Test"
  }
}
