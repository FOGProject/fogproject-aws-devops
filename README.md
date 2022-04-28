# Introduction

This repository represents FOG Project's AWS account completely as code. The Infrastructure-as-code language used is Terraform. Automation that exists in this account is also housed here.

## IaC Structure

The `tf_init` directory creates an S3 bucket intended for Terraform remote state files only. This bucket is named `terraform-remote-state-158698670377`. All Terraform project's remote state should be stored here within at least one subdirectory. State files should end with the `.json` file extension. State files other than the tf_init state file itself are prohibited from being checked into revision control.

The `tf_base_us-east-1` directory houses common components to be used in the AWS region us-east-1. There is a `README.md` in this directory.

The `tf_modules` directory houses custom-built Terraform modules used by various other Terraform projects within this repository. There is a `README.md` in this directory.

Other directories in this repository vary in nature and structure, though all should contain `README.md` files describing what they are, how to use them, and contribution guidelines.

All Terraform projects within this repository should include a `versions.tf` file specifying a version of Terraform and provider versions. The `~>` operator should be used to lock Terraform and provider versions to a major version while allowing for minor version upgrades, as major version upgrades should be purposeful and not accidental.

## AWS Resource Naming Standards

All Terraform resource names should use snake_case, and all AWS resource names should use snake_case wherever possible. Variables and locals used to populate names dynamically should all use snake_case, and where resources utilize these variables and locals while also needing hyphens instead of underscores, string replace should be used for that resource name. Below is an example of this for a Route53 record. This is to reduce the effort required when changing a name within a project. A name change should only need to occur in one variable, or one locals, or one tfvars file, rather than needing changed in many places.

```
locals {
  project_name = "awesome_project_name"
}

resource "aws_route53_record" "subdomain_example" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "${replace(local.project_name, "_", "-")}.fogproject.us"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.lb.public_ip]
}
```

NOTE: directly defining names that require hyphens is fine too, as long as the components of the name are paramaterized. Such as S3 bucket names. See the example below showing this.


For resources that have global names (such as S3 buckets), the resource name should include the AWS Account ID (via data source), and the region name. 

For resources that have account-wide names (such as IAM resources), the region name should be included.

For example, the us-east-1 logging bucket name is created as follows.

```
resource "aws_s3_bucket" "log_bucket" {
  bucket = "logging-${var.region}-${data.aws_caller_identity.current.account_id}"
}
```

It is recommended to append 4 random characters to resource names that are region-wide (such as Secrets Manager resources). An example below shows how to create an AWS Secrets manager resource with random characters appended to it's name.

```
resource "random_string" "ssh_key_random_name_append" {
  length  = 4
  special = false
  lower   = true
  number  = true
  upper   = false
}

resource "aws_secretsmanager_secret" "ssh_private_key" {
  name        = "ssh_private_key_${random_string.ssh_key_random_name_append.result}"
  description = "This is meant to be a team-accessible key, not belonging to any one person."
}
```

For items residing within a VPC (such as security groups), the VPC Name should be included in the resource name. Below is an example.

```
locals {
  vpc_name = "${var.project}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = local.vpc_name
  }
}

resource "aws_security_group" "internet_connectivity" {
  name        = "${local.vpc_name}_internet_connectivity"
  description = "This allows dns, http, and https."
  vpc_id      = aws_vpc.vpc.id
}
```

## AWS Tagging Standards

All Terraform stacks creating AWS resources shoud utilize Terraform provider default tags. This feature was introduced in Terraform 0.12.31 and is available in all later versions. The default tags should include a `project` tag at minimum, and this project tag should be specific and unique to the Terraform project.

Name tags on individual resources is encouraged but not required.

Below is an example of provider default tags usage.

```
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      project = "common-us-east-1"
    }
  }
}
```

Please be aware of the known issues with provider default tags, and avoid them: https://support.hashicorp.com/hc/en-us/articles/4406026108435-Known-issues-with-default-tags-in-the-Terraform-AWS-Provider 

## Secrets

Secrets in code are absolutely prohibited. If the Terraform or automation needs secrets, Secrets Manager resources should be used to house the secret, and other various automation can be used to access the secret value as needed.

Secret population is the responsibility of FOG Project. Written instructions for producing, populating, and testing the secret is the code contributor's responsibility. These instructions should be included in a `README.md` in your code submission. FOG Project will not share any secrets generated.


## Contributing

All Terraform submitted should have passed a tflint test:
https://github.com/terraform-linters/tflint 

tflint should not give any warnings or errors for newly submitted Terraform code.

The standards in this readme should be adhered to, and best practices used where the readme defines none.

Pull requests should be submitted to the `main` branch for consideration. After code review is completed, tflint validation completed, terraform plan validation completed, and a successful apply is performed using your branch, and possibly after other considerations are met, the pull request is merged. All code submissions must accept this repository's LICENSE file.

