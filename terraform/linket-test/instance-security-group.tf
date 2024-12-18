module "master_sg" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-master-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    "calico-bgp" = {
      from_port   = 179
      to_port     = 179
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    ipinip = {
      from_port   = -1
      to_port     = -1
      ip_protocol = "4"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "kube-api-server" = {
      from_port   = 6443
      to_port     = 6443
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "nfs-port" = {
      from_port   = 2049
      to_port     = 2049
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "kube-scheduler" = {
      from_port   = 10259
      to_port     = 10259
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "node-exporter" = {
      from_port   = 9100
      to_port     = 9100
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    kubelet = {
      from_port   = 10250
      to_port     = 10250
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

module "devops_sg" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-devops-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    kubelet = {
      from_port   = 10250
      to_port     = 10250
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "kube-proxy" = {
      from_port   = 10256
      to_port     = 10256
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "node-exporter" = {
      from_port   = 9100
      to_port     = 9100
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "metrics-server" = {
      from_port   = 8443
      to_port     = 8443
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "prometheus-server" = {
      from_port   = 9090
      to_port     = 9090
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "alertmanager" = {
      from_port   = 9093
      to_port     = 9093
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "calico-bgp" = {
      from_port   = 179
      to_port     = 179
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    "vault-node-port" = {
      from_port   = 30003
      to_port     = 30005
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

module "elk_sg" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-elk-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }

    elastic = {
      from_port   = 9200
      to_port     = 9200
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }

    logstash = {
      from_port   = 5033
      to_port     = 5033
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }

    kibana = {
      from_port   = 5601
      to_port     = 5601
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    kibanainternet = {
      from_port   = 30008
      to_port     = 30008
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }

    prometheus = {
      from_port   = 9100
      to_port     = 9100
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    calico = {
      from_port   = 179
      to_port     = 179
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    kubelet = {
      from_port   = 10250
      to_port     = 10250
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    kubeproxy = {
      from_port   = 10256
      to_port     = 10256
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    ipinip = {
      from_port   = -1
      to_port     = -1
      ip_protocol = "4"
      cidr_ipv4   = "10.0.16.0/20"
    }
  }
}

module "worker_0_sg" {
  source  = "app.terraform.io/animal-squad/security-group/aws"
  version = "1.0.1"

  name_prefix = "${local.name}-worker_0-sg"
  vpc_id      = module.network.vpc_id

  ingress_rules = {
    "node-exporter" = {
      from_port   = 9100
      to_port     = 9100
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    "kube-proxy" = {
      from_port   = 10256
      to_port     = 10256
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "nginx-ingress-controller-healthz" = {
      from_port   = 10254
      to_port     = 10254
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    ipinip = {
      from_port   = -1
      to_port     = -1
      ip_protocol = "4"
      cidr_ipv4   = "10.0.16.0/20"
    }
    "nginx-ingress-nodeport" = {
      from_port   = 30001
      to_port     = 30001
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    kubelet = {
      from_port   = 10250
      to_port     = 10250
      ip_protocol = "TCP"
      cidr_ipv4   = "10.0.16.0/20"
    }
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "TCP"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}
