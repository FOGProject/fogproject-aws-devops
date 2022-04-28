

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project = "common"
    }
  }
}




data "aws_caller_identity" "current" {}




resource "aws_s3_bucket" "remote_state" {
  bucket = "terraform-remote-state-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name    = "terraform-remote-state-${data.aws_caller_identity.current.account_id}"
  }
}
resource "aws_s3_bucket_logging" "remote_state" {
  bucket        = aws_s3_bucket.remote_state.id
  target_bucket = aws_s3_bucket.remote_state_logging.id
  target_prefix = "s3/${aws_s3_bucket.remote_state.id}"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state" {
  bucket = aws_s3_bucket.remote_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_acl" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  acl    = "private"
}
output "remote_state_bucket" {
  value = aws_s3_bucket.remote_state.id
}





resource "aws_s3_bucket" "remote_state_logging" {
  bucket = "terraform-remote-state-logging-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name    = "terraform-remote-state-logging-${data.aws_caller_identity.current.account_id}"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state_logging" {
  bucket = aws_s3_bucket.remote_state_logging.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "remote_state_logging" {
  bucket = aws_s3_bucket.remote_state_logging.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_acl" "remote_state_logging" {
  bucket = aws_s3_bucket.remote_state_logging.id
  acl    = "private"
}

