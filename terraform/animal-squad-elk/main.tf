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

locals {
  name = "animal-squad-elk"
}

module "elastic_search_instance_sg" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-sg"
  vpc_id      = "vpc-0838db5b7df5ef68b"

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    kibanainternet = {
      from_port   = 30008
      to_port     = 30008
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    kibana = {
      from_port   = 5601
      to_port     = 5601
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    elastic = {
      from_port   = 9200
      to_port     = 9200
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    calico = {
      from_port   = 179
      to_port     = 179
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    kubelet = {
      from_port   = 10250
      to_port     = 10250
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    kibana = {
      from_port   = 5601
      to_port     = 5601
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    logstash = {
      from_port   = 5033
      to_port     = 5033
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    kubeproxy = {
      from_port   = 10256
      to_port     = 10256
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.0.0/20"
    }
    ipinip = {
      from_port   = -1
      to_port     = -1
      ip_protocol = "4"
      cidr_ipv4   = "10.0.0.0/20"
    }
  }
}

module "elastic_search_instance" {
  source  = "app.terraform.io/animal-squad/ec2/aws"
  version = "1.0.2"

  name_prefix = "${local.name}-instance"

  ami           = "ami-096099377d8850a97"
  az            = "ap-northeast-2b"
  instance_type = "t4g.medium"

  security_group_ids          = [module.elastic_search_instance_sg.id]
  subnet_id                   = "subnet-001a1b2a18e96f5d9"
  vpc_id                      = "vpc-0838db5b7df5ef68b"
  associate_public_ip_address = true

  root_volume_size = 50

  key_name = "animal-squad-test"

  user_data = <<-EOF
                  #!/bin/bash
                  hostnamectl set-hostname elk-worker
                  EOF
}
