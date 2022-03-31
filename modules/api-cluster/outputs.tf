# The module output will be retrieve using module.<module_name>.<output>
output "ns_name" {
  value       = var.name_space
  description = "The namespace of the sub cluster"
}

# Maybe use spec.port 0 node_port go-template='{{(index .spec.ports 0).nodePort}}
# Might need to back to name
output "k_service" {
  value = kubernetes_service.api_cluster.spec[0].port[0].node_port
}

output "k_alb_ip" {
  value = kubernetes_service.api_cluster.status[0].load_balancer[0].ingress[0].hostname
}
