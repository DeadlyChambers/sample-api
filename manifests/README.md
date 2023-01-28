# Argo Rollouts

https://github.com/argoproj/argo-rollouts
After instaling rollouts add this to the argocd namespace
```shell
m8sctl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/rollout-extension/v0.3.0/manifests/install.yaml
m8sctl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
m8sctl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
m8sctl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/dashboard-install.yaml
```

Create a role via cli

```shell
argocd cluster add $(m8sctl config get-contexts -o name)

PROJ=default
APP=sample-api
ROLE=jenkins-deployer-role
argocd proj role create $PROJ $ROLE
argocd proj role create-token $PROJ $ROLE -e 10m
JWT=<value from command above>
argocd proj role list $PROJ
argocd proj role get $PROJ $ROLE
```

I was trying to install this but ended up just sort of piece mealing
parts in 
```yaml

apiVersion: kustomize.config.k8s.io/v1alpha
kind: Kustomization

resources:
  - https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
  - https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml
  - https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/crd/kustomization.yaml

#  - https://github.com/argoproj/argo-rollouts/manifests/crds\?ref\=stable
#  - https://github.com/argoproj/argo-rollouts/manifests/install.yaml
#  - https://github.com/argoproj/argo-rollouts/manifests/dashboard-install.yaml

components:
  - https://github.com/argoproj-labs/argocd-extensions/manifests
  - https://github.com/argoproj/argo-rollouts/manifests/crds

```