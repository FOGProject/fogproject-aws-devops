
data "aws_caller_identity" "current" {}


variable "region" {
  type    = string
  default = "us-east-1"
}


variable "project" {
  type    = string
  default = "common"
}
