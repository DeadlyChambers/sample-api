# Helm

Run Once

```shell
ln -s ~/.docker/config.json /var/snap/microk8s/common/var/lib/config.json

```

Run to update creds

```shell
_repo="503517101544.dkr.ecr.us-east-1.amazonaws.com"
_app='system'
_version=1.0.0
_name="sample-api/${_app}"
export DOCKER_BUILDKIT=1
aws sso login
aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin $_repo
```

Run to update cluster

```shell
m8sctl apply -f namespace.yaml
m8sctl apply -f system.api.yaml
m8sctl apply -f ingress.yaml
```