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


# using data rather than hard-coding the ID to keep it out of revision control.
data "aws_route53_zone" "selected" {
  name         = "fogproject.us."
  private_zone = false
}

output "zone_name" {
  value = data.aws_route53_zone.selected.name
}

output "zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}


module "keep_instances_on" {
    source = "../modules/keep_instances_on"
}
