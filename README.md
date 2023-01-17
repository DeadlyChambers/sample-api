# App

```shell
docker build -t sample-api-system:latest -f system.Dockerfile

./docker-run.sh 1.0.0 system sample-api
```

## System Api

**before running** - update the _version number. This will be visible if you navigagte
to the uri it opens the container to, and add system. Should be something like `http://localhost:9000/system`

```shell
## ECR
_repo="503517101544.dkr.ecr.us-east-1.amazonaws.com"
_app='system'
_version=1.0.0
_name="sample-api/${_app}"
export DOCKER_BUILDKIT=1
aws sso login
aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin $_repo
podman build --target deploy -t "${_repo}/${_name}:latest" -t "${_repo}/${_name}:${_version}" --build-arg APP_VER="${_version}" -f "${_app}.Dockerfile" .
#podman tag $_name:latest /sample-api/system:latest
podman push "${_repo}/${_name}:latest"
podman push "${_repo}/${_name}:${_version}"

## Docker hub
_repo='docker.io/deadlychambers'
_app='system'
_version=1.0.0
_name="soinshane-k8s-${_app}"
export DOCKER_BUILDKIT=1
podman build --target deploy -t "${_repo}/${_name}:latest" -t "${_repo}/${_name}:${_version}" --build-arg APP_VER="${_version}" -f "${_app}.Dockerfile" .
#podman tag $_name:latest /sample-api/system:latest
podman push "${_repo}/${_name}:latest"
podman push "${_repo}/${_name}:${_version}"

```

Post Deploy validate version

```shell
_ip=$(m8sctl get ep -n sample-api -o jsonpath='{.items[0].subsets[0].addresses[0].ip}')
curl $_ip/system -s | jq -r '.version'
```

## Data Api

**before running** - update the _version number. This will be visible if you navigagte
to the uri it opens the container to, and add system. Should be something like `http://localhost:9001/system`


```shell
## ECR
_repo="503517101544.dkr.ecr.us-east-1.amazonaws.com"
_app='data'
_version=1.0.0
_name="sample-api/${_app}"
export DOCKER_BUILDKIT=1
aws sso login
aws ecr get-login-password --region us-east-1 | podman login --username AWS --password-stdin $_repo
podman build --target deploy -t "${_repo}/${_name}:latest" -t "${_repo}/${_name}:${_version}" --build-arg APP_VER="${_version}" -f "${_app}.Dockerfile" .
podman push "${_repo}/${_name}:latest"
podman push "${_repo}/${_name}:${_version}"

## Docker hub
_repo='docker.io/deadlychambers'
_app='data'
_version=1.0.0
_name="soinshane-k8s-${_app}"
export DOCKER_BUILDKIT=1
podman build --target deploy -t "${_repo}/${_name}:latest" -t "${_repo}/${_name}:${_version}" --build-arg APP_VER="${_version}" -f "${_app}.Dockerfile" .
#podman tag $_name:latest /sample-api/system:latest
podman push "${_repo}/${_name}:latest"
podman push "${_repo}/${_name}:${_version}"

```

## Updating K8s

After you have ran either of the services, you should be able to 
`cd helm` and `m8sctl apply -f system.api.yaml` this will create the
service, ingress, and deployment with whatever version number is in
the yaml file.

After it is deployed you should be able to go to the endpoints and hit
/system to see the version number output. A deployment of a "new version"
should just be 

```shell
## tag
_ip=$(m8sctl get ep -n sample-api -o jsonpath='{.items[0].subsets[0].addresses[0].ip}')
curl $_ip/system -s | jq -r '.version'
m8sctl set image deployment/system -n sample-api system=docker.io/deadlychambers/soinshane-k8s-system:1.0.1
m8sctl rollout restart deployment/system -n sample-api
## Maybe use this
m8sctl scale --replicas=1 deployment system

## master
m8sctl patch deployment system -p \
  '{"spec":{"template":{"spec":{"terminationGracePeriodSeconds":31}}}}'
```