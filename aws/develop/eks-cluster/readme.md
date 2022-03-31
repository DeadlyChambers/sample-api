# Create EKS Cluster
Using [OLD ~~Terraform Example~~](https://learn.hashicorp.com/tutorials/terraform/eks?in=terraform/kubernetes) a ,uch more recent example is here
[New](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v18.17.0/examples/eks_managed_node_group)

## File Breakdown

### **Main**
**vpc.tf** Creating the VPC, and starts with cluster name, and loadbalancer naming with random values as the suffix. Here is where you will want to specify Region and/or cidr range for the VPC and subnets. Results will create a 3 public and 3 private subnets with a nat gateway setup

**security-groups.tf** Is setting up the ssh ingress to from local to public subnets, and public subnets to private subnets on the vpc.

**kubernetes.tf** Is the final piece to create the ssl and expose the vpc. Meaning once
this guy is in place. The eks cluster should be ready to be deployed to. 

**versions.tf** Sets the terraform provider versions used

**eks.tf** Will be creating the ec2 worker nodes that will be part of the eks cluster

**outputs.tf** Upon completion of the terraform apply, the output that will be given will
be the major pieces required for deploying to minikube. To pick up the ec2 deployments, we just need to configure kubectl with the values output. Kube.config, host, and cert provided by terraform. Will enable configuration for eks cli

**dashboard-admin.rbac.yaml** Used later to authenticate to the dashboard using the ssl cert created as part of the k8s cluster creation

```
# Create EKS Cluster
aws sso login
terraform init
terraform plan
terraform apply

# Extract SSL Cert for Auth
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

## Install Metrics and Dashboard
They are installing the metrics server and the k8s dashboard into the cluster as they are not installed by default. 
```

# Metrics Server
wget -O v0.3.6.tar.gz https://codeload.github.com/kubernetes-sigs/metrics-server/tar.gz/v0.3.6 && tar -xzf v0.3.6.tar.gz
kubectl apply -f metrics-server-0.3.6/deploy/1.8+/
kubectl get deployment metrics-server -n kube-system

# Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

## And setup a proxy to the dashboard
kubectl proxy
```
[Dashboard](http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)


## Auth to Dashboard
Create a Role Based Access Control using the ssl cert genereated during k8s cluster creation and configure the dashboard with that token. 
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')
```


## Destory
That should have provisioned an EKS Cluster, now you can either deploy, or destroy.
```
terraform destroy
```

## Deploy
Start in the services folder
```
cd ../services
```