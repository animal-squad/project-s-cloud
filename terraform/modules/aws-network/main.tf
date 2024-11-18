resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

locals {
  az_for_signle_nat = slice(var.private_nat_subnet_azs, 0, min(1, length(var.private_nat_subnet_azs)))
  az_for_multi_nat  = distinct(var.private_nat_subnet_azs)
  az_for_nat        = var.create_multi_nat ? local.az_for_multi_nat : local.az_for_signle_nat

  private_cidir_start        = length(var.public_subnet_azs)
  private_nat_cidir_start    = length(var.public_subnet_azs) + length(var.private_subnet_azs)
  public_for_nat_cidir_start = length(var.public_subnet_azs) + length(var.private_subnet_azs) + length(var.private_nat_subnet_azs)
}

/*
  Public Subnet
*/

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name_prefix}-ig"
  }
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in var.public_subnet_azs : idx => az }

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.public_subnet_azs, each.key)
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.key)

  tags = {
    Name = "${var.name_prefix}-public-subnet-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
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

resource "aws_subnet" "private" {
  for_each = zipmap(var.private_subnet_azs, range(length(var.private_subnet_azs)))

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, local.private_cidir_start + each.value)

  tags = {
    Name = "${var.name_prefix}-private-subnet-${each.value}"
  }
}

/*
  Private Subnet + NAT
*/

resource "aws_subnet" "public_for_nat" {
  for_each = zipmap(local.az_for_nat, range(length(local.az_for_nat)))

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, local.public_for_nat_cidir_start + each.value)

  tags = {
    Name = format(
      "%s-public-nat-subnet-%s",
      var.name_prefix,
      var.create_multi_nat ? each.value : ""
    )
  }
}

resource "aws_eip" "nat" {
  for_each = zipmap(local.az_for_nat, range(length(local.az_for_nat)))

  domain = "vpc"

  tags = {
    Name = format(
      "%s-eip-%s",
      var.name_prefix,
      var.create_multi_nat ? each.value : ""
    )
  }

  depends_on = [aws_route.public_internet_gateway]
}

resource "aws_nat_gateway" "public_nat" {
  for_each = zipmap(local.az_for_nat, range(length(local.az_for_nat)))

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public_for_nat[each.key].id

  tags = {
    Name = format(
      "%s-nat-%s",
      var.name_prefix,
      var.create_multi_nat ? each.value : ""
    )
  }

  depends_on = [aws_route.public_internet_gateway]
}

resource "aws_subnet" "private_nat" {
  for_each = zipmap(var.private_nat_subnet_azs, range(length(var.private_nat_subnet_azs)))

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, local.private_nat_cidir_start + each.value)

  tags = {
    Name = format(
      "%s-private-subnet-nat-%s",
      var.name_prefix,
      each.value
    )
  }
}

resource "aws_route_table" "private_nat" {
  for_each = zipmap(var.private_nat_subnet_azs, range(length(var.private_nat_subnet_azs)))

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format(
      "%s-private-nat-route-table-%s",
      var.name_prefix,
      each.value
    )
  }
}

resource "aws_route_table_association" "private_nat" {
  for_each = aws_subnet.private_nat

  subnet_id      = aws_subnet.private_nat[each.key].id
  route_table_id = aws_route_table.private_nat[each.key].id
}

resource "aws_route" "private_ec2_nat_gateway" {
  for_each = aws_subnet.private_nat

  route_table_id         = aws_route_table.private_nat[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public_nat[each.key].id
}
