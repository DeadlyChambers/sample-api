#Do it with just helm, skip the extra terraform boilerplate
#https://www.architect.io/blog/2021-02-17/terraform-kubernetes-tutorial/
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}
provider "kubernetes" {
  config_path = "<your_kubeconfig_path>"
}
provider "helm" {
  kubernetes {
    config_path = "<your_kubeconfig_path>"
  }
}