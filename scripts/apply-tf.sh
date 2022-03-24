# Create System Api in MiniKube w/Terraform
#terraform apply -var 'var.current_api=system-api' -var 'docker_tag=6.0.1.11' -var 'docker_image=soinshane-k8s-system'

# Create Data Api in Minikube w/Terraform
terraform apply -var 'current_api=data-api' -var 'docker_tag=6.0.1.10' -var 'docker_image=soinshane-k8s-data'