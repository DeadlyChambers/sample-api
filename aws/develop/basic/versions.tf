terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.1"
    }

    # random = {
    #   source  = "hashicorp/random"
    #   version = ">= 3.1"
    # }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1"
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