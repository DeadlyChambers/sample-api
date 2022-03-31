terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.9.0"
    }
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../eks-cluster/terraform.tfstate"
  }
}

# Retrieve EKS cluster information
provider "aws" {
  region  = "sample-api-p0zcdzln" #data.terraform_remote_state.eks.outputs.region
  profile = "AdministratorAccess-503517101544"
}


# apiVersion: v1
# clusters:
# - cluster:
#     server: endpoint
#     certificate-authority-data: certificate-data
#   name: kubernetes
# contexts:
# - context:
#     cluster: kubernetes
#     user: aws
#   name: aws
# current-context: aws
# kind: Config
# preferences: {}
# users:
# - name: aws
#   user:
#     exec:
#       apiVersion: client.authentication.k8s.io/v1alpha1
#       command: aws
#       args:
#         - "eks"
#         - "get-token"
#         - "--cluster-name"
#         - "cluster-name"
#         # - "--role-arn"
#         # - "role-arn"
#       # env:
#         # - name: AWS_PROFILE
#         #   value: "aws-profile"

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
  #endpoint = data.aws_eks_cluster.cluster.endpoint
  #certificate_authority = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
  #   cluster {

  #   }
}

resource "kubernetes_namespace" "api_cluster" {
  metadata {
    name = "develop"
  }

}

module "system-api" {
  source       = "../../../modules/api-cluster"
  name_space   = kubernetes_namespace.api_cluster.metadata[0].name
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
  source       = "../../../modules/api-cluster"
  name_space   = kubernetes_namespace.api_cluster.metadata[0].name
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
