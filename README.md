# App

```shell
docker build -t sample-api-system:latest -f system.Dockerfile

./docker-run.sh 1.1.0 system sample-api
```

## System Api

**before running** - update the _version number. This will be visible if you navigagte
to the uri it opens the container to, and add system. Should be something like `http://localhost:9000/system`

```shell
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

```

## Data Api

**before running** - update the _version number. This will be visible if you navigagte
to the uri it opens the container to, and add system. Should be something like `http://localhost:9001/system`


```shell
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

```
