# Apis
There are two .net api projects. When they are built and deploy you will be able to hit the endpoint /System to get assembly and version information to be able to know information about the state of the apis. These apis are nested with the docker files as
the next step from application code, is to get the image prepared for Terraform/K8s

# Minikube Config
I added `minikube addons enable ingress` and ingress-dns [See Docs](/home/shane/source/repos/dotnet/sample-api/readme.md)
That will act as a dns server, so I am able to use a load balancer without a tunnel.

## Creating a namespace on cluster
```
k apply -f k8s/namespace-*.yaml
```

Set the context
```
k config view
# pull cluster, and user for the next command

k config set-context dev --namespace=dev --cluster=minikube --user=minikube
k config set-context prd --namespace=prd --cluster=minikube --user=minikube
k config use-context dev
k config current-context
```

# Building Docker
Below are a lot of the commands you need to create images, run kube state configs, and validate the state of your nodes, services, deployments, pods, minikube, and other kubernate objects
```

# Update vars for both images
_app_ver=6.0.1.8
_app_proj=system# or system

# Build the new images
docker build -t "deadlychambers/soinshane-k8s-$_app_proj:$_app_ver" -t "deadlychambers/soinshane-k8s-$_app_proj:latest" --build-arg APP_VER=$_app_ver -f "$_app_proj.Dockerfile" . 

# push the images
docker push "deadlychambers/soinshane-k8s-$_app_proj" -a
```

## Run a container
You can connect to the container and checkout things from the inside if need be

```
docker pull "deadlychambers/soinshane-k8s-$_app_proj:latest"

docker run -t -d --name api-service "deadlychambers/soinshane-k8s-$_app_proj:latest"


docker ps -a

#now you can execute command on the container
docker exec -it api-service bash
```

### Cleanup
A little awk and xargs magic to cleanup all of the images that are from the deadlychambers repo on my local
```
docker image ls | grep deadlychambers | awk '$1=="deadly*";{print $3}' | xargs docker rmi --force
```