terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8"
    }


    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.9.0"
    }

  }

  required_version = ">= 0.14"
}
