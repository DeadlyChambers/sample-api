# Auth to Kubectl
The aws eks get-token --region us-east-1 --cluster-name sample-api-6jScXn4S is the ticket, then plug in the other values below. It really should be feed through Terra, but it is being a pain.
```

apiVersion: v1
clusters:
- cluster:
    server: https://C54FC867CF5075636EFA63BFDF7363EA.gr7.us-east-2.eks.amazonaws.com
    certificate-authority-data: asdfstCg==
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "k8s-aws-v1.part.jwt"
        - "-i"
        - "clusertname"
        # - "-r"
        # - "role-arn"
      # env:
        # - name: AWS_PROFILE
        #   value: "aws-profile"
```

# Deploy to K8s in AWS
If you are here, it is assumed that you have ran k8s-cluster, and followed the readme to create the cluster and stand up the dashboard. [Per Terraform Documentation](https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider) Now kubectl should be hydrated with data needed to be able to create deployments/services/pods on the cluster that are serving up the application.
```
terraform init
terraform plan
terraform apply
```

Make sure the ELB has role
```
aws iam get-role --role-name "AWSServiceRoleForElasticLoadBalancing" || aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"
```