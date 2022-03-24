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

# variable "client_certificate" {
#   type = string
# }

# variable "client_key" {
#   type = string
# }

# variable "cluster_ca_certificate" {
#   type = string
# }

variable "app_name" {
  type = string
}

variable "current_api" {
  type = string
  validation {
    condition = can(regex("^system", "${var.current_api}")) || can(regex("^data", "${var.current_api}"))
    error_message = "The current_api needs to begin with system, or data."
  }
}

variable "docker_image" {
  type = string
  validation {
    condition = can(regex("system$", "${var.docker_image}")) || can(regex("data$", "${var.docker_image}"))
    error_message = "The docker_image needs to end with system, or data."
  }
}
variable "docker_tag" {
  type = string
}
variable "docker_repo" {
  type = string
}

variable "replicas" {
  type = number
}

provider "kubernetes" {
  host        = var.host
  config_path = "~/.kube/config"
  #   client_certificate     = base64decode(var.client_certificate)
  #   client_key             = base64decode(var.client_key)
  #   cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_namespace" "develop" {
  metadata {
    name = "develop"
  }
}

resource "kubernetes_deployment" "develop" {
  metadata {
    name      = var.current_api
    namespace = kubernetes_namespace.develop.metadata.0.name
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        msservice = var.current_api
      }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 1
        max_surge       = 2
      }
    }
    template {
      metadata {
        labels = {
          msservice = "${var.current_api}"
          app       = "${var.app_name}"
        }
      }
      spec {
        container {
          image     = "${var.docker_repo}/${var.docker_image}:${var.docker_tag}"
          name      = var.current_api
          port {
            container_port = 80
          }
          image_pull_policy = "Always"
          resources {
            requests = {
              memory = "65Mi"
              cpu    = "125m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "250m"
            }
          }
          port {
            container_port = 80
          }
          readiness_probe {
            http_get {
              path = "/System"
              port = 80
            }
            initial_delay_seconds = 5
            timeout_seconds       = 5
          }
          liveness_probe {
            http_get {
              path = "/System"
              port = 80
            }
            initial_delay_seconds = 5
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "develop" {
  metadata {
    name      = var.current_api
    namespace = kubernetes_namespace.develop.metadata.0.name
    labels = {
      msservice = var.current_api
      app       = var.app_name
    }
  }
  spec {
    selector = {
      msservice = kubernetes_deployment.develop.spec.0.template.0.metadata.0.labels.msservice
    }
    type = "NodePort"
    port {
      node_port   = 31122
      port        = 8080
      target_port = 80
    }
  }
}