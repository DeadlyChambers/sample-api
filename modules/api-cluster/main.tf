
##About to strip working code into modules. Want to get a quick 
##commit in just in case I melt this design

resource "kubernetes_deployment" "api_cluster" {
  metadata {
    name      = var.current_api
    namespace = var.name_space
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
          image = "${var.docker_repo}/${var.docker_image}:${var.docker_tag}"
          name  = var.current_api
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

resource "kubernetes_service" "api_cluster" {
  metadata {
    name      = var.current_api
    namespace = var.name_space
    labels = {
      msservice = var.current_api
      app       = var.app_name
    }
  }
  spec {

    selector = {
      msservice = kubernetes_deployment.api_cluster.spec.0.template.0.metadata.0.labels.msservice
    }
    type = var.service_type
    port {
      #node_port   = 31122
      port        = var.port
      target_port = 80
    }
  }
}
