terraform {
  backend "s3" {
    bucket = "terraform-remote-state-158698670377"
    key    = "common/tf_base_us-east-1.json"
    region = "us-east-1"
  }
}


provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project = "common-us-east-1"
    }
  }
}
