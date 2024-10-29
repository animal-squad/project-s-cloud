locals {
  flat_default_target = flatten([
    for tg_name, tg_data in var.default_target_groups : [
      for instance in tg_data.target : {
        tg_name = tg_name
        id      = instance.id
        port    = instance.port
      }
    ]
  ])
  flat_target = flatten([
    for tg_name, tg_data in var.listener_rule : [
      for instance in rule_data.target : {
        rule_index = idx
        id         = instance.id
        port       = instance.port
      }
    ]
  ])
}

/*
  보안 그룹
*/

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

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.sg.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  description = "http ingress rule"

  tags = {
    Name = "${var.name_prefix}-http-ingress-rule"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  description = "https ingress rule"

  tags = {
    Name = "${var.name_prefix}-https-ingress-rule"
  }
}

/*
  ALB
*/

resource "aws_lb" "alb" {
  name_prefix        = var.name_prefix
  load_balancer_type = "application"

  subnets         = var.subnet_ids
  security_groups = [aws_security_group.alb.id]

  client_keep_alive = 3600 // Default
  idle_timeout      = var.idle_timeout

  enable_deletion_protection = var.enable_deletion_protection
}

/*
  ALB Listener
*/

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn

  port     = "80"
  protocol = "HTTP"


  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  certificate_arn   = var.certificate_arn

  //NOTE: ssl_policy 설정 값 참조 https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html
  ssl_policy = "ELBSecurityPolicy-TLS13-1-0-2021-06"
  port       = "443"
  protocol   = "HTTPS"


  default_action {
    type = "forward"

    forward {
      dynamic "target_group" {
        for_each = aws_lb_target_group.default_target_group

        content {
          arn = each.value.arn
        }
      }
    }
  }
}

resource "aws_lb_target_group" "default_target_group" {
  for_each = var.default_target_groups

  health_check {
    path = each.value.health_check_path
  }

  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"

  name_prefix = "${var.name_prefix}-default-tg-${each.key}"
  port        = each.value.port

  preserve_client_ip = true

  protocol         = "HTTP"
  protocol_version = "HTTP2"

  target_type = "instance"

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-default-tg-${each.key}"
  }
}

resource "aws_lb_target_group_attachment" "default_target" {
  for_each = {
    for instance in local.flat_default_target : "${instance.tg_name}-${instance.id}" => instance
  }

  target_group_arn = aws_lb_target_group.default_target_group[each.value.tg_name].arn
  target_id        = each.value.id
  port             = each.value.port
}

/*
  ALB Listener Rule
*/

resource "aws_lb_listener_rule" "rules" {
  for_each = var.listener_rule

  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_groups[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path
    }
  }

  condition {
    host_header {
      values = each.value.host
    }
  }
}

resource "aws_lb_target_group" "target_groups" {
  for_each = var.listener_rule

  health_check {
    path = each.value.health_check_path
  }

  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"

  name_prefix = "${var.name_prefix}-tg-${each.key}"
  port        = each.value.port

  preserve_client_ip = true

  protocol         = "HTTP"
  protocol_version = "HTTP2"

  target_type = "instance"

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-tg-${each.key}"
  }
}

resource "aws_lb_target_group_attachment" "default_target" {
  for_each = {
    for instance in local.flat_target : "${instance.rule_index}-${instance.id}" => instance
  }

  target_group_arn = aws_lb_target_group.target_groups[each.value.rule_index].arn
  target_id        = each.value.id
  port             = each.value.port
}
