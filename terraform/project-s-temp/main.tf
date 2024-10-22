provider "aws" {
  region     = local.region
  # access_key = //TODO: 키 발급해야 함
  # secret_key = //TODO: 키 발급해야 함

  default_tags {
    tags = {
      Environment = "temp"
      CreatedBy   = "Terraform"
    }
  }
}

locals {
  name   = basename(path.cwd)
  azs    = data.aws_availability_zones.available.names
  region = "ap-northeast-2" //NOTE: 서울

  vpc_cidr = "10.0.0.0/20" //NOTE: 계정 내에서 중복된 cidr를 선언하지 않았는지 확인 필요

  //TODO: 상세 스펙 Apply 전 다시 한 번 확인하기
  rds_config = {
    db_name        = "tempdbforprojects"
    engine_version = "14.13"
    username       = "animalsquad"
    password       = "animalsquadpassword" //XXX: 실제 환경에서 사용하면 안됨
    port           = "5432"
  }

  ec2_config = {
    ami           = "ami-096099377d8850a97" // NOTE: region 별로 ami 코드가 다를 수 있음.
    instance_type = "t4g.medium"
  }
}

//NOTE: private key
resource "tls_private_key" "for_ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "for_ec2" {
  key_name   = "${local.name}-key"
  public_key = tls_private_key.for_ec2.public_key_openssh
}

output "private_key_path" {
  value     = tls_private_key.for_ec2.private_key_pem
  sensitive = true
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
  vpc_id = aws_vpc.vpc.id

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
  vpc_id = aws_vpc.vpc.id

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
  Private Subnet For EC2
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

resource "aws_route_table" "private_ec2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name}-private-ec2-route-table"
  }
}

# resource "aws_route" "private_ec2_nat_gateway" {
#   route_table_id         = aws_route_table.private_ec2.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.public_nat_gateway.id
# }

resource "aws_route" "private_internet_gateway" {
  route_table_id         = aws_route_table.private_ec2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private_for_ec2[count.index].id
  route_table_id = aws_route_table.private_ec2.id
}

/*
  Private Subnet For RDS
*/

resource "aws_subnet" "private_for_rds" {
  count = 2

  vpc_id            = aws_vpc.vpc.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(local.vpc_cidr, 4, 3 + count.index)

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

  depends_on = [aws_route.public_internet_gateway]
}

resource "aws_nat_gateway" "public_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${local.name}-${local.azs[0]}-nat-gateway"
  }

  depends_on = [aws_route.public_internet_gateway]
}

/*
  RDS
*/

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.name}-rds-subnet-group"
  subnet_ids = aws_subnet.private_for_rds[*].id //NOTE: 필수적으로 2개 이상의 az를 다루어야 함

  tags = {
    Name = "${local.name}-rds-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${local.name}-rds-sg"
  description = "${local.name} rds security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = local.rds_config.port
    to_port         = local.rds_config.port
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_for_master.id, aws_security_group.ec2_for_worker.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  //TODO: 상세 스펙 Apply 전 다시 한 번 확인하기
  allocated_storage       = 20
  max_allocated_storage   = 1000
  instance_class          = "db.t3.micro"
  backup_retention_period = 0
  backup_target           = "region"
  port                    = local.rds_config.port

  db_name                      = local.rds_config.db_name
  engine                       = "postgres"
  engine_version               = "14.13"
  username                     = local.rds_config.username
  password                     = local.rds_config.password
  skip_final_snapshot          = true
  availability_zone            = local.azs[1]
  performance_insights_enabled = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}

/*
  EC2
*/

resource "aws_security_group" "ec2_for_master" {
  name        = "${local.name}-sg-ec2-m"
  description = "security group of ec2 for master"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_for_master" {
  instance_type = local.ec2_config.instance_type

  //TODO: 상세 스펙 Apply 전 다시 한 번 확인하기
  ami                         = local.ec2_config.ami
  availability_zone           = local.azs[0]
  subnet_id                   = aws_subnet.private_for_ec2[0].id
  security_groups             = [aws_security_group.ec2_for_master.id]
  key_name                    = aws_key_pair.for_ec2.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${local.name}-${local.azs[0]}-ec2-for-master"
  }

  ebs_block_device {
    //TODO: 상세 스펙 Apply 전 다시 한 번 확인하기
    device_name           = "/dev/sdb"
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true

    tags = {
      Name = "${local.name}-${local.azs[0]}-ec2-for-master"
    }
  }
}

resource "aws_security_group" "ec2_for_worker" {
  name        = "${local.name}-sg-ec2-w"
  description = "security group of ec2 for worker"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_for_worker" {
  instance_type = local.ec2_config.instance_type

  //TODO: 상세 스펙 Apply 전 다시 한 번 확인하기
  ami                         = local.ec2_config.ami
  availability_zone           = local.azs[1]
  subnet_id                   = aws_subnet.private_for_ec2[1].id
  security_groups             = [aws_security_group.ec2_for_worker.id]
  key_name                    = aws_key_pair.for_ec2.key_name
  associate_public_ip_address = true


  tags = {
    Name = "${local.name}-${local.azs[1]}-ec2-for-worker"
  }

  ebs_block_device {
    //TODO: 상세 스펙 Apply 전 다시 한 번 확인하기
    device_name           = "/dev/sdb"
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${local.name}-${local.azs[1]}-ec2-for-worker"
    }
  }

}

/*
  ALB
*/

resource "aws_security_group" "alb" {
  name        = "${local.name}-sg-alb"
  description = "security group of alb"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 445
    protocol    = "tcp"
    description = "HTTPS web traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 82
    protocol    = "tcp"
    description = "HTTP web traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name              = "${local.name}-alb"
  subnets           = aws_subnet.private_for_ec2[*].id
  security_groups   = [aws_security_group.alb.id]
  client_keep_alive = 3600 // Default
}

resource "aws_lb_target_group" "ec2" {
  name     = "${local.name}-tg-ec2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "ec2_master" {
  target_group_arn = aws_lb_target_group.ec2.arn
  target_id        = aws_instance.ec2_for_master.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_worker" {
  target_group_arn = aws_lb_target_group.ec2.arn
  target_id        = aws_instance.ec2_for_worker.id
  port             = 80
}

//XXX: 현재 HTTP 통신중 HTTPS로 통신해야 함
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2.arn
  }
}
