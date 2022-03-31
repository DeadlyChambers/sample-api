# Deploy to K8s in AWS
If you are here, it is assumed that you have ran k8s-cluster, and followed the readme to create the cluster and stand up the dashboard. [Per Terraform Documentation](https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider) Now kubectl should be hydrated with data needed to be able to create deployments/services/pods on the cluster that are serving up the application.
```
terraform init
terraform plan
terraform apply
```