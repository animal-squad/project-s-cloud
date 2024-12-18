locals {
  name = "linket-test"
}

provider "aws" {
  region     = "ap-northeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      Production = local.name
      CreatedBy  = "terraform"
    }
  }
}

module "network" {
  source  = "app.terraform.io/animal-squad/network/aws"
  version = "1.0.4"

  name_prefix    = local.name
  vpc_cidr_block = "10.0.16.0/20"

  public_subnet = {
    alb_0 = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 0)
    }
    alb_1 = {
      az         = "ap-northeast-2b"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 1)
    }
    master = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 2)
    }
    devops = {
      az         = "ap-northeast-2b"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 3)
    }
    elk = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 4)
    }
    worker_0 = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 5)
    }
    rds_0 = {
      az         = "ap-northeast-2a"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 6)
    }
    rds_1 = {
      az         = "ap-northeast-2b"
      cidr_block = cidrsubnet("10.0.16.0/20", 8, 7)
    }
  }

  enable_dns_hostnames = true
}
