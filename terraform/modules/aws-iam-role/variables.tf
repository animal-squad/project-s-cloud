/*
  공통 사항
*/

variable "name_prefix" {
  description = "EC2 구성 요소들의 이름과 tag을 선언하는데 사용될 prefix."
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 50
    error_message = "이름에 사용될 prefix는 50자를 넘을 수 없습니다."
  }
}

/*
  IAM Role 설정
*/

variable "iam_policy_arn" {
  description = "IAM Role에 적용될 policy의 arn"
  type        = string
}

variable "principal_type" {
  description = "IAM Role의 Principal type"
  type        = string
}

variable "principal_identifier" {
  description = "IAM Role의 Principal identifier"
  type        = string
}


/*
  관리 편의성 설정
*/

variable "force_detach_policies" {
  description = "해당 role을 삭제할 경우 자동으로 role을 사용하고 있는 요소들에서 분리됩니다. 해당 옵션을 false로 할 경우 수동으로 분리하거나 해당 값을 true로 변경한 후에 role을 제거해야지만 정상적으로 삭제가 진행됩니다."
  type        = bool
  default     = true
}
