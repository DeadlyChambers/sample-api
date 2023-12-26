# Working App

Under sample-api is the working
image connections for 2 microservices.

I commented out the part that would be 
handled by aws.

```shell
m8sctl apply -f ./sample-api
```

### Update image via deployment/rollout

```shell
m8sctl set image deployment/data-app -n sample-api data-container=public.ecr.aws/deadlychambers/sample-api/data:1.0.1
m8sctl set image deployment/system-app -n sample-api system-container=public.ecr.aws/deadlychambers/sample-api/system:1.0.1
```

### Auth for pods

```shell
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 503517101544.dkr.ecr.us-east-1.amazonaws.com
```