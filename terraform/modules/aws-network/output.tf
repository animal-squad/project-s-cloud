output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = [for idx, az in var.public_subnet_azs : aws_subnet.public[idx].id]
}
