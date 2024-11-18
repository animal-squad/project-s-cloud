resource "aws_db_subnet_group" "subnet_group" {
  name_prefix = "${var.name_prefix}-rds-subnet-group"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-rds-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  instance_class        = var.instance_class

  engine         = var.engine
  engine_version = var.engine_version
  db_name        = var.db_name
  username       = var.username
  password       = var.password
  port           = var.port

  backup_retention_period = var.backup_retention_period
  backup_target           = var.backup_target

  availability_zone      = var.availability_zone
  vpc_security_group_ids = var.security_group_ids

  db_subnet_group_name = aws_db_subnet_group.subnet_group.name

  skip_final_snapshot          = true
  performance_insights_enabled = true

  publicly_accessible = var.publicly_accessible

  tags = {
    Name = "${var.name_prefix}-rds"
  }
}
