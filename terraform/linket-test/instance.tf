module "instance" {
  for_each = {
    master = {
      az        = "ap-northeast-2a"
      type      = "t4g.small"
      sg_ids    = [module.master_sg.id]
      root_size = 50
    }
    devops = {
      az        = "ap-northeast-2b"
      type      = "t4g.medium"
      sg_ids    = [module.devops_sg.id]
      root_size = 20
    }
    elk = {
      az        = "ap-northeast-2a"
      type      = "t4g.medium"
      sg_ids    = [module.elk_sg.id]
      root_size = 50
    }
    worker_0 = {
      az        = "ap-northeast-2a"
      type      = "t4g.small"
      sg_ids    = [module.worker_0_sg.id]
      root_size = 20
    }
  }

  source  = "app.terraform.io/animal-squad/ec2/aws"
  version = "1.0.2"

  name_prefix = "${local.name}-instance-server-${each.key}"

  ami           = "ami-096099377d8850a97"
  az            = each.value.az
  instance_type = each.value.type

  security_group_ids          = each.value.sg_ids
  subnet_id                   = module.network.public_subnets[each.key].id
  vpc_id                      = module.network.vpc_id
  associate_public_ip_address = true

  root_volume_size = each.value.root_size

  key_name = "animal-squad-test"

  user_data = <<-EOF
                  #!/bin/bash
                  hostnamectl set-hostname ${each.key}
                  EOF
}
