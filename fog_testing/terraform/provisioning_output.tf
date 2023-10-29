

resource "aws_s3_bucket" "provisioning" {
  bucket = "provisioning-${var.region}-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "provisioning-${var.region}-${data.aws_caller_identity.current.account_id}"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "provisioning" {
  bucket = aws_s3_bucket.provisioning.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "provisioning" {
  bucket = aws_s3_bucket.provisioning.id
  versioning_configuration {
    status = "Disabled"
  }
}
resource "aws_s3_bucket_acl" "provisioning" {
  bucket = aws_s3_bucket.provisioning.id
  acl    = "private"
}
resource "aws_s3_bucket_lifecycle_configuration" "provisioning" {
  bucket = aws_s3_bucket.provisioning.id
  rule {
    status = "Enabled"
    id     = "delete_old_files"
    expiration {
      days = 2
    }
  }
}
resource "aws_s3_bucket_logging" "provisioning" {
  bucket        = aws_s3_bucket.provisioning.id
  target_bucket = data.terraform_remote_state.base.outputs.log_bucket
  target_prefix = "s3/${aws_s3_bucket.provisioning.id}"
}










resource "aws_iam_instance_profile" "provisioning" {
  name = "${var.project}-provisioning"
  role = aws_iam_role.provisioning.name
}

resource "aws_iam_role_policy" "provisioning" {
  name = "${var.project}-provisioning"
  role = aws_iam_role.provisioning.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "output",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${aws_s3_bucket.provisioning.arn}",
                "${aws_s3_bucket.provisioning.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "provisioning" {
  name               = "${var.project}-provisioning"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
