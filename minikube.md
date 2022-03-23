# Minikube Config
I added `minikube addons enable ingress` and ingress-dns [See Docs](/home/shane/source/repos/dotnet/sample-api/readme.md)
That will act as a dns server, so I am able to use a load balancer without a tunnel.

## Creating a namespace
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