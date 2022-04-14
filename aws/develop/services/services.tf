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

variable "auth_token" {
  description = "The token for context"
  type = "string"
}

data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../eks-cluster"
  }
}


locals {
  #namespace    = "develop"
  docker_repo = "deadlychambers"
  docker_image = "deadlychambers"
  context_name = "terraform"
  context_user = "terraform"
  #May need to pull from 
  #_token=$(aws eks get-token --cluster-name sample-api --region us-east-2 | jq -r .status.token)
  #terraform apply -var "auth_token=${_token}" && terraform output
  auth_token   = var.auth_token
  hosturl      = data.terraform_remote_state.eks.cluster_endpoint
  ca_cert_data = data.terraform_remote_state.eks.cluster_certificate_authority_data
  cluster_name = data.terraform_remote_state.eks.cluster_id
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
    labels = {
      app=local.cluster_name
    }
    name = local.namespace
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
  docker_repo  = local.docker_repo
  app_name     = local.cluster_name
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
  docker_repo  = local.docker_repo
  app_name     = local.cluster_name
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
