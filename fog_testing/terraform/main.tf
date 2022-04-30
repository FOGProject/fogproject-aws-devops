
resource "aws_route53_zone" "private-zone" {
  name = "fogtesting.cloud"
  vpc {
    vpc_id = data.terraform_remote_state.base.outputs.vpc_id
  }
}


terraform {
  backend "s3" {
    bucket = "terraform-remote-state-158698670377"
    key    = "fog_aws_testing/remote_state.json"
    region = "us-east-1"
  }
}


provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project = "fogtesting"
    }
  }
}


data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "terraform-remote-state-158698670377"
    key    = "common/tf_base_${var.region}.json"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}
