terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.9.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1"
    }
  }
}

locals {
  namespace    = "develop"
  context_name = "kube-system"
  context_user = "aws-node"
  auth_token   = "k8s-aws-v1.jwt.part"
  hosturl      = "https://your.eks.amazonaws.com"
  ca_cert_data = "S0tLS0tCg=="
  cluster_name = "api-cluster"
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = local.context_name
    contexts = [{
      name = local.context_name
      context = {
        cluster = local.cluster_name
        user    = local.context_user
      }
    }]
    users = [{
      name = local.context_user
      user = {
        token = local.auth_token
      }
    }]

    clusters = [{
      name = local.cluster_name
      cluster = {
        certificate-authority-data = base64decode(local.ca_cert_data)
        server                     = local.hosturl
      }
    }]
  })
}

resource "kubernetes_namespace" "develop" {
  metadata {
    name = local.namespace
  }
}
provider "kubernetes" {
  host                   = local.hosturl
  token                  = local.auth_token
  cluster_ca_certificate = base64decode(local.ca_cert_data)
  config_context         = local.context_name
}

module "system-api" {
  source       = "../../../../modules/api-cluster"
  name_space   = resource.kubernetes_namespace.develop.metadata[0].name
  current_api  = "system-api"
  docker_tag   = "6.0.1.11"
  docker_image = "soinshane-k8s-system"
  docker_repo  = "deadlychambers"
  app_name     = "sample-app"
  service_type = "LoadBalancer"
  port         = 80
  replicas     = 1
}

module "data-api" {
  source       = "../../../../modules/api-cluster"
  name_space   = resource.kubernetes_namespace.develop.metadata[0].name
  current_api  = "data-api"
  docker_tag   = "6.0.1.10"
  docker_image = "soinshane-k8s-data"
  docker_repo  = "deadlychambers"
  app_name     = "sample-app"
  service_type = "LoadBalancer"
  port         = 80
  replicas     = 1
}

output "system_lb_ip" {
  value = module.system-api.k_alb_ip
  #modules.system-api.k_service
}

output "data_lb_ip" {
  value = module.data-api.k_alb_ip
  #modules.data-api.k_service
}
