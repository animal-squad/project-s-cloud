resource "aws_security_group" "sg" {
  name_prefix = "${var.name_prefix}-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.sg.id
  description       = "default egress ec2"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "${var.name_prefix}-egress-rule"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  security_group_id = aws_security_group.sg.id

  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.ref_sg_id

  tags = {
    Name = "${var.name_prefix}-ingress-rule-${each.key}"
  }
}

resource "aws_instance" "ec2" {
  instance_type = var.instance_type
  ami           = var.ami

  availability_zone           = var.az
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = concat([aws_security_group.sg.id], var.additional_security_group_ids)

  key_name = var.key_name


  iam_instance_profile = var.role_name == null ? null : aws_iam_instance_profile.profile[0].name
  user_data            = var.user_data

  tags = {
    Name = "${var.name_prefix}-ec2"
  }
}

resource "aws_ebs_volume" "ebs" {
  count = var.ebs_size == null ? 0 : 1

  availability_zone = var.az
  type              = "gp3"
  size              = var.ebs_size

  tags = {
    Name = "${var.name_prefix}-ebs"
  }

  depends_on = [aws_instance.ec2]
}

resource "aws_volume_attachment" "ebs_att" {
  count = var.ebs_size == null ? 0 : 1

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs[0].id
  instance_id = aws_instance.ec2.id
}

// NOTE: Instance Role

resource "aws_iam_instance_profile" "profile" {
  for_each = var.role_name == null ? toset([]) : toset([var.role_name])

  name = "${var.name_prefix}_profile"
  role = each.key
}
