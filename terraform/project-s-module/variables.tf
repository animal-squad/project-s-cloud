data "aws_regions" "available" {}

data "aws_availability_zones" "available" {}

variable "region" {
  description = "작업이 진행 될 Region"
  type        = string

  validation {
    condition     = contains(data.aws_regions.available.names, var.region)
    error_message = "사용 불가능한 Region을 명시하고있습니다."
  }
}
