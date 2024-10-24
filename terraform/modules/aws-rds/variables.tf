/*
  공통 사항
*/

variable "name_prefix" {
  description = "RDS 구성 요소들의 이름과 tag을 선언하는데 사용될 prefix."

  validation {
    condition     = length(var.name_prefix) <= 50
    error_message = "이름에 사용될 prefix는 50자를 넘을 수 없습니다."
  }
}

/*
  서브넷 그룹
*/

variable "subnet_ids" {
  description = "RDS subnet group 생성 시 사용될 subnet id 목록. 필수적으로 2개 이상의 AZ를 포함"
  type        = set(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = ""
  }
}

/*
  DB 사양
*/

variable "allocated_storage" {
  description = "DB에 할당 할 저장 공간의 크기(GB). max_allocated_storage 속성을 사용한 경우 저장 공간의 시작 크기로 사용."
  type        = number
}

variable "max_allocated_storage" {
  description = "DB 저장 공간의 최대 크기(GB). 해당 속성을 사용할 경우 저장 공간이 부족할 경우 자동으로 저장 공간을 확장 함"
  type        = number
  default     = 0
}

variable "instance_class" {
  description = "RDS에 사용할 인스턴스 유형"
  type        = string
}

/*
  백업
*/

variable "backup_retention_period" {
  description = "백업 보존 기간 (일)"
  type        = number
  default     = null
}

variable "backup_target" {
  description = "백업 저장 위치"
  type        = string
  default     = null
}

/*
  DB 유형 및 설정
*/

variable "engine" {
  description = "RDS 생성에 사용할 DB 엔진 유형"
  type        = string
}

variable "engine_version" {
  description = "RDS 생성에 사용할 DB 엔진의 버전 정보"
  type        = string
}

variable "db_name" {
  description = "DB 이름"
  type        = string
}

variable "username" {
  description = "DB 관리자 이름"
  type        = string
}

variable "password" {
  description = "DB 관리자"
  type        = string
}

variable "port" {
  description = "DB 연결 포트"
  type        = number
}


/*
  기타
*/

variable "availability_zone" {
  description = "RDS를 구축할 AZ 위치. 명시적으로 특정 AZ를 선택하고 싶을때만 사용. 명시하지 않을 경우 subnet group에서 사용중인 AZ 중 임의로 할당"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "RDS에 적용 될 보안 그룹 id 목록"
  type        = set(string)
}
