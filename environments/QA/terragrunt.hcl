terraform {
  extra_arguments "retry_lock" {
    commands  = ["get_terraform_commands_that_need_locking()"]
    arguments = [
      "-lock-timeout=60m"
    ]
  }
}

inputs = {
  aws_account_id         = "290786573471"
  name                   = "gwell"
  environment            = "qa"
  region                 = "us-east-1"
  bucket_name            = "s3-website-khadgi"
  bucket_name_event      = "s3-website-khadgi-2"
}