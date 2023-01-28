# Apis
There are two .net api projects. When they are built and deploy you will be able to hit the endpoint /System to get assembly and version information to be able to know information about the state of the apis. These apis are nested with the docker files as
the next step from application code, is to get the image prepared for Terraform/K8s



# Building Docker
Below are a lot of the commands you need to create images, run kube state configs, and validate the state of your nodes, services, deployments, pods, minikube, and other kubernate objects
```

# Check versions of Docker Images to know what the next version should be
./.docker-check.sh

# Update the version below for the specific api, system or data
_app_proj=system
_api_version=6.0.1.12

# Update vars for both images
./.docker-run.sh $_api_version $_app_proj
## or
./.docker-run.sh $_api_version $_app_proj
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