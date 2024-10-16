provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "production"
      CreatedBy   = "Terraform"
    }
  }
}

locals {
  name = basename(path.cwd)
  azs  = data.aws_availability_zones.available.names

  vpc_cidr = "192.168.0.0/20"
}

resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr

  tags = {
    Name = "${local.name}-vpc"
  }
}
