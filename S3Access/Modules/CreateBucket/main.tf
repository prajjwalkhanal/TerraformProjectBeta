resource "aws_s3_bucket" "my-s3-bucket" {
  bucket_prefix = "${var.bucket_prefix}"
  acl = "private"
  versioning {
    enabled = true
  }
  tags = var.tags
}