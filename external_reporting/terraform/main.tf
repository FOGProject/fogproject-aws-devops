# Backends cannot use interpolation.
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-158698670377"
    key    = "external_reporting/remote_state.json"
    region = "us-east-1"
  }
}


provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project = "external_reporting"
    }
  }
}


variable "region" {
  type    = string
  default = "us-east-1"
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "terraform-remote-state-158698670377"
    key    = "common/tf_base_${var.region}.json"
    region = "us-east-1"
  }
}
