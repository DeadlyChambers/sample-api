# Deploy Apis to EKS Cluster in AWS
If you want to create new images follow the next step or else skip ahead to [Create EKS Cluster](#create-eks-cluster)

# Images
The system, and data images will be put into ECR in AWS to prepare for the deployment to EKS.

```
aws sso login

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/w7a3q5r4
```

Then update the images in ECR
```
cd ./api

# Check versions of Docker Images to know what the next version should be
./.docker-check.sh

# Update the version below for the specific api, system or data
_app_proj=system
_api_version=6.0.1.12

# Update vars for both images
./.docker-run.sh $_api_version $_app_proj "aws"

_app_proj=data
_api_version=6.0.1.11
./.docker-run.sh $_api_version $_app_proj "aws"

# Update the images with the updated tags
cd ./aws
nano develop/services/kubernetes.tf
```


# <a name="create-eks-cluster"></a>Creating EKS Cluster
[See eks-cluster](eks-cluster/readme.md)
The Terraform Configs were built following [Terraform Documentation](https://learn.hashicorp.com/tutorials/terraform/eks?in=terraform/kubernetes)


## Then schedule a deployment
[See services](services/readme.md)
The Terraform Configs were built following [Terraform Documentation](https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider)
Except instead of using an nginx image, I used the api service modules created as part of my initial Terraform K8s project. Instead of using a k8s cluster on MiniKube, I'm using an k8s cluster in AWS [Api Cluster](./../modules/api-cluster/main.tf) 

# Test the deployment
After creating the services you should be able to get the IP:Port
```
./.test-deploy.sh develop
```

## Destroy the api and cluster
After you are able to hit the api successfully. Destroy the api and the eks cluster to not incurr costs.
```
cd services
terraform destroy
cd ../eks-cluster
terraform destroy
```