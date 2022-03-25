# K8S Sample App
There are 2 simple apis under the api folder `system` and `data` services. They are built
on .net 6.0. In the same directory are docker files, and 

## Modular Composition
Terraform consider best practice keeping your modules at max 1 layer deep, and utiize
expressions for nesting, and modules together on a single module. They warn that if you nest modules several layers deep. It becomes difficult to make isolated changes to the the infrastructure layout. 

## Quick Start
You should be able to copy paste, just double check docker hub that you have a higher version of the docker image
```
## Find versions you would use
./docker-check.sh

## Data Api
./run-docker.sh 6.0.1.<x> data
# k is assuming you have the alias setup
k apply -f data.kube.yaml
export data_port=$(kubectl get services/data-api -o go-template='{{(index .spec.ports 0).nodePort}}')
curl "http://$(minikube ip):${data_port}/System"

## System Api
./run-docker.sh 6.0.1.<x> system
k apply -f system.kube.yaml
export system_port=$(kubectl get services/system-api -o go-template='{{(index .spec.ports 0).nodePort}}')
curl "http://$(minikube ip):${system_port}/System"

```
