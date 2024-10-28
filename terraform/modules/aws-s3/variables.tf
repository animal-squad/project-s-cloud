/*
  공통 사항
*/

variable "name_prefix" {
  description = "S3 구성 요소들의 이름과 tag을 선언하는데 사용될 prefix. S3 bucket name 규칙으로 인해 37자 이상은 안 됨"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 37
    error_message = "이름에 사용될 prefix는 37자를 넘을 수 없습니다."
  }
}

/*
  버킷 설정
*/

variable "force_destroy" {
  description = "s3를 제거하는 명령어를 실행할 때 locked object가 있어도 terraform이 강제로 제거하는것을 허용할지 여부"
  type        = bool
  default     = false
}

variable "object_lock_enabled" {
  description = "s3에 생성 된 object를 자동으로 잠글것인지 여부. 덮어쓰기, 삭제등이 불가능해진다. 버전관리와 함께 사용한다면 덮어쓰기가 가능(버전별로 생성되므로)"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "s3 object 버전관리 적용 여부 (Disabled은 최초 생성시에만 설정 가능합니다.)"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning)
    error_message = "Enabled, Suspended, Disabled만 가능합니다."
  }
}

/*
  권한 설정
*/

variable "object_ownership" {
  description = "s3를 제거하는 명령어를 실행할 때 locked object가 있어도 terraform이 강제로 제거하는것을 허용할지 여부"
  type        = string
  default     = "ObjectWriter"

  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.object_ownership)
    error_message = "object_ownership은 BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced만 가능합니다."
  }
}

variable "public_access_block" {
  description = "s3 버킷 level에서 퍼블릭 접근 제한 관련 설정"
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })

  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "acl" {
  description = "s3 버킷 level에서 퍼블릭 접근 제한 관련 설정. 'https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl'에서 사용 가능한 값을 확인할 수 있음"
  type        = string
  default     = "private"
}


/*
  접근 권한 설정
*/

variable "bucket_policy" {
  description = "bucket 정책"
  type        = string
  default     = null
}
