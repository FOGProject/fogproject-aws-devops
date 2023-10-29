terraform {
  required_version = "= 1.6.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.23.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "= 3.4.0"
    }
  }
}
