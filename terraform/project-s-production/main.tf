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

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.vpc_id

  tags = {
    Name = "${local.name}-ig"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = local.azs[0]
  cidr_block        = cidrsubnet(local.vpc_cidr, 4, 0)

  tags = {
    Name = "${local.name}-${local.azs[0]}-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = vpc.vpc.vpc_id

  tags = {
    Name = "${local.name}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
