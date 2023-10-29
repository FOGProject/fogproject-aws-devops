resource "aws_s3_bucket" "log_bucket" {
  bucket = "logging-${var.region}-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "logging-${var.region}-${data.aws_caller_identity.current.account_id}"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_acl" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "private"
}
output "log_bucket" {
  value = aws_s3_bucket.log_bucket.id
}

