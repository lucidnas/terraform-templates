# A S3 Bucket for the Alloy App

resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-app-${var.environment}"

  tags = {
    Name        =  "${var.name}-app-${var.environment}"
    Environment =  var.environment
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  block_public_acls   = true
  block_public_policy = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule { # Used default S3 SSE. if bucket needs to be accessed by another account, we can specify own key and use aws:kms option
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}
