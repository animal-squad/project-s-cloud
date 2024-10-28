terraform {
  required_version = "~>1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0.0" # 필요에 따라 원하는 버전 설정
    }
  }
}
