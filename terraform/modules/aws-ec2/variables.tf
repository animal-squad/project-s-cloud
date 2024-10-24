/*
  공통 사항
*/

variable "name_prefix" {
  description = "EC2 구성 요소들의 이름과 tag을 선언하는데 사용될 prefix."
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "이름에 사용될 prefix는 20자를 넘을 수 없습니다."
  }
}

/*
  보안 그룹
*/

variable "vpc_id" {
  description = "보안 그룹을 생성 할 vpc의 id"
  type        = string
}

variable "ingress_rules" {
  description = "ingress 규칙 목록"

  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = optional(string)
    ref_sg_id   = optional(string)
  }))

  default = []
}

/*
  인스턴스
*/

variable "instance_type" {
  description = "EC2의 인스턴스 타입"
  type        = string
}

variable "ami" {
  description = "EC2의 AMI"
  type        = string
}

variable "az" {
  description = "EC2의 AZ"
  type        = string
}

variable "subnet_id" {
  description = "EC2의 subnet id"
  type        = string
}

variable "additional_security_group_ids" {
  description = "EC2에 적용할 추가 sg"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "EC2에 public ip 할당 여부"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "EC2에서 사용 할 aws key pair의 이름"
  type        = string
  default     = null
}

variable "ebs_size" {
  description = "EC2에서 사용 할 EBS의 용량"
  type        = number
  default     = null
}
