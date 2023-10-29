terraform {
  required_version = "= 1.6.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.23.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.5.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "= 2.4.0"
    }
  }
}
