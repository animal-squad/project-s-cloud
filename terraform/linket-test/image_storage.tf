module "image_storage_test" {
  source  = "app.terraform.io/animal-squad/s3/aws"
  version = "1.0.0"

  name_prefix = "${local.name}-web"

  object_lock_enabled = true

  versioning = "Enabled"
}
