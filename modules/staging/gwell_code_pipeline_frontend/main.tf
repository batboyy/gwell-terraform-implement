// terraform {
//   backend "s3" {}
//   required_version = "0.13.4"
// }

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  version                 = ">= 2.28.1"
}



resource "aws_s3_bucket" "gwellBucket" {
  bucket = "gwell-pawan-sunit-123-123"
  acl    = "private"

  
}


#Code_Pipeline
resource "aws_codepipeline" "gwell_pipeline" {
  name     = "gwell-editorial-staging-frontend"
  role_arn = aws_iam_role.CodePipelineAssumeRole.arn

  artifact_store {
    location = aws_s3_bucket.gwellBucket.bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
     
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      namespace        = "SourceVariables"


      configuration = {
        S3Bucket = "gitstorebucker"
        S3ObjectKey = "staging.zip"
        PollForSourceChanges = "false"
       
      }
input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]

    }
  }

  stage {
    name = "Build"

    action {
    
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      
      version         = "1"
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = aws_codebuild_project.CodeBuildProject.name
      }
  input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]

      
    }
  }


stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "BucketName" = "test-static-website-sunit"
        "Extract"    = "true"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = "1"
      namespace        = "DeployVariables"
    }
  }


}

