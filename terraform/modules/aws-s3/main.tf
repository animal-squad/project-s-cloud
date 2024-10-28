resource "aws_s3_bucket" "s3" {
  bucket_prefix = var.name_prefix

  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled

  tags = {
    Name = "${var.name_prefix}-s3-bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.s3.id

  versioning_configuration {
    status = var.versioning
  }
}


//NOTE: 버킷 소유권 설정
resource "aws_s3_bucket_ownership_controls" "s3_ownershipt" {
  bucket = aws_s3_bucket.s3.id

  rule {
    object_ownership = var.object_ownership
  }
}

//NOTE: 버킷 접근 제한 관련 설정
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.s3.id
  acl    = var.acl

  depends_on = [
    aws_s3_bucket_ownership_controls.s3_ownershipt,
    aws_s3_bucket_public_access_block.public_access_block,
  ]
}

//NOTE: 버킷 정책

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  count = var.bucket_policy == null ? 0 : 1

  bucket = aws_s3_bucket.s3.id
  policy = var.bucket_policy
}
