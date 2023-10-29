terraform {
  required_version = "= 1.6.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.23.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "= 2.2.0"
    }
  }
}
