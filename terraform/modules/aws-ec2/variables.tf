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

variable "user_data" {
  description = "EC2에서 최초 생성 시 실행될 스크립트"
  type        = string
  default     = null
}

/*
  IAM Role
*/

variable "assign_role_to_ec2" {
  description = "EC2 Instance에 Role을 부여할것인지 여부"
  type        = bool
  default     = false
}

variable "role_name" {
  description = "EC2 Instance에 부여 할 Role name"
  type        = string
  default     = null

  validation {
    condition     = !(var.assign_role_to_ec2 && var.role_name == null)
    error_message = "assign_role_to_ec2가 true일 경우 role_name을 지정해야 합니다."
  }
}
