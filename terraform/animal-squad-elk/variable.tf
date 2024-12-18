variable "aws_access_key" {
  description = "aws access key"
  type        = string

  validation {
    condition     = var.aws_access_key != null && var.aws_access_key != ""
    error_message = "TFC에서 받아오지 않을 경우 에러 발생"
  }
}

variable "aws_secret_key" {
  description = "aws secret key"
  type        = string

  validation {
    condition     = var.aws_secret_key != null && var.aws_secret_key != ""
    error_message = "TFC에서 받아오지 않을 경우 에러 발생"
  }
}
