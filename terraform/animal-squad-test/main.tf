provider "aws" {
  region     = "ap-northeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      Environment = "test"
      CreatedBy   = "terraform"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name = "animal-squad-test"

  azs = data.aws_availability_zones.available.names
  //NOTE: ec2-m, ec2-g-w1, ec2-g-w2, ec2-v-w, ec2-cicd-w, rds, rds 순서
  public_subnet_azs = [local.azs[0], local.azs[0], local.azs[1], local.azs[1], local.azs[2], local.azs[1], local.azs[0], local.azs[1]]
  vpc_cidr          = "10.0.0.0/20" //NOTE: 계정 내에서 중복된 cidr를 선언하지 않았는지 확인 필요

  ec2_ami = "ami-096099377d8850a97"

  rds_port = "5432"
}

/*
  AWS Key Pair
*/

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = local.name
  public_key = tls_private_key.key_pair.public_key_openssh
}

/*
  네트워크 자원
*/

module "network" {
  source = "github.com/animal-squad/project-s-cloud/terraform/modules/aws-network"

  name_prefix       = local.name
  cidr_block        = local.vpc_cidr
  public_subnet_azs = local.public_subnet_azs
}

module "ec2-master" {
  source = "github.com/animal-squad/project-s-cloud/terraform/modules/aws-ec2"

  name_prefix = "${local.name}-master"

  vpc_id    = module.network.vpc_id
  az        = local.public_subnet_azs[0]
  subnet_id = module.network.public_subnet_ids[0]

  associate_public_ip_address = true

  instance_type = "t4g.small"
  ami           = local.ec2_ami
  user_data     = <<-EOF
                  #!/bin/bash
                  hostnamectl set-hostname master
                  EOF

  ingress_rules                 = local.k8s_common_ingress_rule
  additional_security_group_ids = [aws_security_group.ec2_rds.id]

  key_name = aws_key_pair.key_pair.key_name

  ebs_size = 30
}

module "ec2-service-worker" {
  count = 2

  source = "github.com/animal-squad/project-s-cloud/terraform/modules/aws-ec2"

  name_prefix = "${local.name}-service-worker-${count.index}"

  vpc_id    = module.network.vpc_id
  az        = local.public_subnet_azs[1 + count.index]
  subnet_id = module.network.public_subnet_ids[1 + count.index]

  associate_public_ip_address = true

  instance_type                 = "t4g.small"
  ami                           = local.ec2_ami
  user_data                     = <<-EOF
                  #!/bin/bash
                  hostnamectl set-hostname worker${count.index + 1}
                  EOF
  ingress_rules                 = local.k8s_common_ingress_rule
  additional_security_group_ids = [aws_security_group.ec2_rds.id]

  key_name = aws_key_pair.key_pair.key_name

  ebs_size = 20
}


module "ec2-vault-worker" {
  source = "github.com/animal-squad/project-s-cloud/terraform/modules/aws-ec2"

  name_prefix = "${local.name}-vault-worker"

  vpc_id    = module.network.vpc_id
  az        = local.public_subnet_azs[3]
  subnet_id = module.network.public_subnet_ids[3]

  associate_public_ip_address = true

  instance_type = "t4g.micro"
  ami           = local.ec2_ami

  user_data                     = <<-EOF
                  #!/bin/bash
                  hostnamectl set-hostname vault-worker
                  EOF
  ingress_rules                 = local.k8s_common_ingress_rule
  additional_security_group_ids = [aws_security_group.ec2_rds.id]

  key_name = aws_key_pair.key_pair.key_name
}

module "ec2-ci-cd-worker" {
  source = "github.com/animal-squad/project-s-cloud/terraform/modules/aws-ec2"

  name_prefix = "${local.name}-ci-cd-worker"

  vpc_id    = module.network.vpc_id
  az        = local.public_subnet_azs[4]
  subnet_id = module.network.public_subnet_ids[4]

  associate_public_ip_address = true

  instance_type                 = "t4g.medium"
  ami                           = local.ec2_ami
  user_data                     = <<-EOF
                  #!/bin/bash
                  hostnamectl set-hostname devops-worker
                  EOF
  ingress_rules                 = local.k8s_common_ingress_rule
  additional_security_group_ids = [aws_security_group.ec2_rds.id]

  key_name = aws_key_pair.key_pair.key_name
}

//FIXME: 보안 그룹 생성도 모듈화 할 필요 있어보임
//NOTE: ec2와 rds를 연결할 때 사용할 보안 그룹
resource "aws_security_group" "ec2_rds" {
  name_prefix = "${local.name}-ec2-rds-sg"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "${local.name}-ec2-rds-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "rds_egress" {
  security_group_id = aws_security_group.ec2_rds.id
  description       = "default egress rds"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "${local.name}-egress-rule"
  }
}

//NOTE: rds에서 사용할 보안 그룹
resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds-sg"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "${local.name}-rds-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.rds.id
  description       = "default egress rds"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "${local.name}-egress-rule"
  }
}



module "rds" {
  source = "github.com/animal-squad/project-s-cloud/terraform/modules/aws-rds"

  name_prefix = local.name

  subnet_ids = slice(module.network.public_subnet_ids, 6, 8)

  allocated_storage     = 20
  max_allocated_storage = 1000
  instance_class        = "db.t3.micro"

  engine         = "postgres"
  engine_version = "14.13"
  db_name        = var.db_name
  username       = var.db_username
  password       = var.db_password
  port           = local.rds_port

  security_group_ids = [aws_security_group.rds.id]
}
