# K8S Configurations
Before starting K8S I went through some tutorials and documentation to compile a detailed basics of K8S, what resources are, and how k8s works in general. That is pureley a [wiki](https://github.com/DeadlyChambers/soinshane-k8s)

## Loadbalancer Type
**TODO**
The Loadbalancer wasn't fully work on minikube, you have to set some stuff up to get it working. I will pick this up later, my issue was not not getting out of pending state, so you [Might need a hack and a fix](https://minikube.sigs.k8s.io/docs/handbook/accessing/#loadbalancer-access)
## Apply to Kubernetes
You need to create the Service and deployment using the yaml files in the directory. Also you might need to ensure the  `minikube start` has happened.

```
kubectl apply -f ./data.kube.yaml -f ./system.kube.yaml 

kubectl get services
kubectl get deployments

kubectl delete service -l msservice="system"
kubectl delete deployment -l msservice="system"
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