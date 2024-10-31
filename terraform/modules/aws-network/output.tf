output "vpc_id" {
  value = aws_vpc.vpc.id
}

//FIXME: 순서를 제대로 보장 할 수 있도록 for_each 구문등으로 변경하는것이 안전함.
output "public_subnet_ids" {
  value = [for idx, az in var.public_subnet_azs : aws_subnet.public[idx].id]
}
