include {
  path = "${find_in_parent_folders()}"
}
remote_state {
  backend = "s3"
  config = {
    bucket         = "suneet-terraform-state"
    key            = "qa/s3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table-sunit"
  }
}
terraform {
  source = "../../..//modules/S3lambda"
  extra_arguments "retry_lock" {
    commands = ["get_terraform_commands_that_need_locking()"]
    arguments = [
      "-lock-timeout=60m",
    ]
  }
  extra_arguments "additional_vars" {
    commands = ["get_terraform_commands_that_need_vars()"]
    optional_var_files = [
      "${get_parent_terragrunt_dir()}/../terragrunt.hcl"
    ]
  }
}

// dependency "vpc" {
//   config_path = "../vpc"
// }

inputs = {
 project_name    = "sunit"

 

}