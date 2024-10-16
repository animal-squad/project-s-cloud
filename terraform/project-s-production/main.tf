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

/*
  VPC
*/

resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr

  tags = {
    Name = "${local.name}-vpc"
  }
}

/*
  Internet Gateway
*/

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.vpc_id

  tags = {
    Name = "${local.name}-ig"
  }
}

/*
  Public Subnet
*/

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

/*
  Private Subnet
*/

resource "aws_subnet" "private_for_ec2" {
  count = 2

  vpc_id            = aws_vpc.vpc.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(local.vpc_cidr, 4, count.index + 1)

  tags = {
    Name = "${local.name}-${local.azs[count.index]}-private-ec2-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_for_rds" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = local.azs[1]
  cidr_block        = cidrsubnet(local.vpc_cidr, 4, 3)

  tags = {
    Name = "${local.name}-${local.azs[count.index]}-private-rds-subnet"
  }
}

/*
  NAT Gateway
*/

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name = "${local.name}-${local.azs[0]}-eip"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "public_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${local.name}-${local.azs[0]}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.this]
}
