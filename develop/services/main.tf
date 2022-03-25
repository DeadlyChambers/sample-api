terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}


variable "host" {
  type = string
}


module "system-api" {
  source = "../../modules/api-cluster"  
  
  [CONFIG ...]
}



provider "kubernetes" {
  host        = var.host
  config_path = "~/.kube/config"
  #   client_certificate     = base64decode(var.client_certificate)
  #   client_key             = base64decode(var.client_key)
  #   cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}