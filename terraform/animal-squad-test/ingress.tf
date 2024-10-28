locals {
  k8s_common_ingress_rule = [
    {
      //NOTE: SSH
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      //NOTE: HTTP
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      //NOTE: HTTPS
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    /*
      Kubernates
    */
    {
      //NOTE: Kube-API-Server
      from_port   = 6443
      to_port     = 6443
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    },
    {
      //NOTE: ETCP(write, read)
      from_port   = 2379
      to_port     = 2380
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    },
    {
      //NOTE: CIN(calico)
      from_port   = 179
      to_port     = 179
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    },
    {
      //NOTE: Kubelet
      from_port   = 10250
      to_port     = 10250
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    },
    {
      //NOTE: Kube-Proxy
      from_port   = 10256
      to_port     = 10256
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    },
    {
      //NOTE: Kube-Control
      from_port   = 10257
      to_port     = 10257
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    },
    {
      //NOTE: Kube-Schedule
      from_port   = 10259
      to_port     = 10259
      ip_protocol = "tcp"
      cidr_ipv4   = local.vpc_cidr
    },
  ]
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress" {
  security_group_id = aws_security_group.rds.id

  from_port                    = local.rds_port
  to_port                      = local.rds_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_rds.id

  tags = {
    Name = "${local.name}-rds-ingress-rule"
  }
}
