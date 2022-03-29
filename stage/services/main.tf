
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.9.0"
    }
  }
}



variable "host" {
  type = string
  # minikube ip; to see what ip you need
  default = "https://192.168.49.2:8443"
}

provider "kubernetes" {
  host        = var.host
  config_path = "~/.kube/config"
  #   client_certificate     = base64decode(var.client_certificate)
  #   client_key             = base64decode(var.client_key)
  #   cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_namespace" "api_cluster" {
  metadata {
    name = "stage"
  }

}

module "system-api" {
  source       = "../../modules/api-cluster"
  name_space   = kubernetes_namespace.api_cluster.metadata[0].name
  current_api  = "system-api"
  docker_tag   = "6.0.1.12"
  docker_image = "soinshane-k8s-system"
  docker_repo  = "deadlychambers"
  app_name     = "sample-app"
  replicas     = 1
}

module "data-api" {
  source       = "../../modules/api-cluster"
  name_space   = kubernetes_namespace.api_cluster.metadata[0].name
  current_api  = "data-api"
  docker_tag   = "6.0.1.11"
  docker_image = "soinshane-k8s-data"
  docker_repo  = "deadlychambers"
  app_name     = "sample-app"
  replicas     = 1
}

# ## Possible change
# variable "ms_names" {
#   description = "Create Api Services from the list"
#   type        = list(string)
#   default     = ["system", "data"]
# }
# module "microservices" {
#   source = "../../modules/api-cluster"  
#   count = length(var.ms_names)
#   current_api  = "${var.ms_names[count.index]}-api"
#   docker_tag   = "latest"
#   docker_image = "soinshane-k8s-${var.ms_names[count.index]}"
#   docker_repo  = "deadlychambers"
#   app_name     = "sample-app"
#   replicas     = 1
# }



## Maybe even a better way
# variable "ms_kvps" {
#   description = "map"
#   type        = map(string)
#   default     = {
#     system      = "6.0.1.11"
#     data = "6.0.1.10"
#   }
#}

# for name in ms_kvps:
#   module `${name}-api` {
#   source = "../../modules/api-cluster"  
#   current_api  = "${name}-api"
#   docker_tag   = "${ms_kvps[name]}"
#   docker_image = "soinshane-k8s-${name}"
#   docker_repo  = "deadlychambers"
#   app_name     = "sample-app"
#   replicas     = 1
# }
