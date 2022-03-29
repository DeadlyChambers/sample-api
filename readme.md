# K8S Sample App
There are 2 simple apis under the api folder `system` and `data` services. They are built
on .net 6.0. In the same directory are docker files, and 

## Modular Composition
Terraform consider best practice keeping your modules at max 1 layer deep, and utiize
expressions for nesting, and modules together on a single module. They warn that if you nest modules several layers deep. It becomes difficult to make isolated changes to the the infrastructure layout. 

## Quick Start
The first section here is creating new images in docker hub. If you just want to fire up
the cluster, skip this block.
```
## Get into api directory
cd api

## Find versions you would use
./docker-check.sh

## Data Api where you replace <x> with the next revision number
./run-docker.sh 6.0.1.<x> data

## System Api where you replace <x> with the next revision number
./run-docker.sh 6.0.1.<x> system

```

Now you will need to ensure the terraform config for the module is set to the image
version you wish to see deployed. 
```
## Get into the terraform directory for services
cd develop/services #could also be cd stage/services

nano develop/services/main.tf
# edit the version number for both services, 
# and double check the ip matches $(minikube ip)
# save the file and exit nano
```

Now the Terraform config is ready, you will need to fire up minikube and deploy
```
minikube start

# Deploy
cd develop/services
terraform init
terraform plan
terraform apply
# you will need to type yes

# Test the deployment
cd ../..
./.test-deploy.sh
```

You should see the output of the version from the module. Now you are safe to
destroy everything from minikube and terraform
```
cd develop/services
terraform destroy
minikube delete
```