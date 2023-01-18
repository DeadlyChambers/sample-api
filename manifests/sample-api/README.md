# Rollouts

The argocd rollout makes the act of rolling containers up and down
a little smoother. It is managed by an argocd rollout controller. The
controller is not used while a deployment isn't being transitioned.

It has a lot of flexibiility, and would probably be the best transition
component for new deployments. A raw k8s deployment doesn't seem to
rotate smoothly. 

[using bluegreen](https://github.com/argoproj/rollouts-demo/tree/master/examples/blue-green)
```shell

#install kustomize if you don't have it
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
mv kustomize ~/.local/bin
kustomize version
kubectl create ns argocd && 
m8sctl kustomize build . | m8sctl apply -f - -n argocd

m8sctl create namespace argo-rollouts
m8sctl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

m8sctl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/rollout-extension/v0.3.0/manifests/install.yaml

# install the cli extension to kubectl
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
# move it to where mk8s is
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

m8sctl apply -f blueGreen.yaml
m8sctl apply -f bluegreen-ingress.yaml
m8sctl apply -f bluegreen-preview-ingress.yaml

kubectl argo rollouts dashboard


```