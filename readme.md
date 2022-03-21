# K8S Sample App
Ensure you are in the root folder. Then you can update the version number, then run _app_proj for both data and system
```
# Update vars for both images
_app_ver=6.0.1.2
_app_proj=data# or system

# Build the new images
docker build -t "deadlychambers/soinshane-k8s-$_app_proj:$_app_ver" -t "deadlychambers/soinshane-k8s-$_app_proj:latest" --build-arg APP_VER=$_app_ver -f "$_app_proj.Dockerfile" . --target restore

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

## Apply to Kubernetes
You need to create the Service and deployment using the yaml files in the directory. Also you might need to ensure the  `minikube start` has happened.

```
kubectl apply -f ./data.kube.yaml -f ./system.kube.yaml 

kubectl get services
kubectl get deployments
```

## Validate Service
You can validate the service is properly exposed via kubernetes service
```
# Replace system-service with the service from get services call
export NODE_PORT=$(kubectl get services/system-service -o go-template='{{(index .spec.ports 0).nodePort}}')
echo NODE_PORT=$NODE_PORT

curl $(minikube ip):$NODE_PORT

# Connect to the container
kubectl get pods --selector=app=sample-api

kubectl get -o json pod system-deployment-578cb5b449-86nv4

kubectl exec system-deployment-578cb5b449-86nv4 -it -- bash -il
```