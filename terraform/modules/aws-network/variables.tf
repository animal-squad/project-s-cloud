/*
  공통 사항
*/

variable "name_prefix" {
  description = "VPC 구성 요소들의 이름과 tag를 선언하는데 사용될 prefix."
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "이름에 사용될 prefix는 20자를 넘을 수 없습니다."
  }
}

/*
  VPC 자원
*/

variable "cidr_block" {
  description = "VPC에 할당 할 CIDR 블럭"
  type        = string
}

variable "public_subnet_azs" {
  description = "public subnet을 생성할 az 항목들"
  type        = list(string)
  default     = []
}

variable "private_subnet_azs" {
  description = "private subnet을 생성할 az 항목들"
  type        = list(string)
  default     = []
}

variable "private_nat_subnet_azs" {
  description = "NAT를 사용하는 private subnet을 생성할 az 항목들. 값이 존재하는 경우에만 NAT를 생성 함"
  type        = list(string)
  default     = []
}

variable "create_multi_nat" {
  description = "NAT를 az별로 생성."
  type        = bool
  default     = false
}
