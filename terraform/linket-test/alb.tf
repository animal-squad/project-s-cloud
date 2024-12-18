module "service_alb" {
  source  = "app.terraform.io/animal-squad/elb/aws"
  version = "1.0.8"

  name = "${local.name}-service"

  certificate_arn = "arn:aws:acm:ap-northeast-2:537124933041:certificate/a5f10d6b-50f4-4b71-adfa-0929165f99e6"

  vpc_id     = module.network.vpc_id
  subnet_ids = [module.network.public_subnets["alb_0"].id, module.network.public_subnets["alb_1"].id]

  default_target_groups = {
    worker = {
      port = 80
    }
  }

  default_targets = {
    worker = {
      target_group_key = "worker"
      target_id        = module.instance.worker_0.instance_id
      port             = 30001
    }
  }

  https_listener_rules = {
    grafana = {
      host     = ["grafana.animal-squad.uk"]
      priority = 2
    }
    jenkins = {
      host     = ["jenkins.animal-squad.uk"]
      priority = 3
    }
    vault = {
      host     = ["vault.animal-squad.uk"]
      priority = 4
    }
    elk = {
      host     = ["elk.animal-squad.uk"]
      priority = 5
    }
  }
  target_groups = {
    grafana = {
      health_check_path = "/api/health"
      port              = 80
    }
    jenkins = {
      health_check_path = "/login"
      port              = 80
    }
    vault = {
      health_check_path = "/v1/sys/health?standbyok=true&sealedcode=200"
      port              = 80
    }
    elk = {
      health_check_path = "/api/status"
      port              = 80
    }
  }
  targets = {
    grafana = {
      target_group_key = "grafana"
      target_id        = module.instance.devops.instance_id
      port             = 30006
    }
    jenkins = {
      target_group_key = "jenkins"
      target_id        = module.instance.devops.instance_id
      port             = 30004
    }
    vault = {
      target_group_key = "vault"
      target_id        = module.instance.devops.instance_id
      port             = 30003
    }
    elk = {
      target_group_key = "elk"
      target_id        = module.instance.elk.instance_id
      port             = 30008
    }

  }
}
