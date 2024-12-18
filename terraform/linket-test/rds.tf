module "rds_sg" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-rds-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    postgres = {
      from_port   = 5432
      to_port     = 5432
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

module "rds" {
  source  = "app.terraform.io/animal-squad/rds/aws"
  version = "1.0.0"

  name_prefix = local.name

  allocated_storage     = 20
  max_allocated_storage = 1000
  instance_class        = "db.t3.micro"

  engine         = "postgres"
  engine_version = "14.13"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  publicly_accessible = true

  security_group_ids = [module.rds_sg.id]
  subnet_ids         = [module.network.public_subnets["rds_0"].id, module.network.public_subnets["rds_1"].id]
  availability_zone  = "ap-northeast-2a"
}
