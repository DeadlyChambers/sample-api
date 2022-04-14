
resource "random_string" "suffix" {
  length  = 8
  special = false
}
locals {
  name            = "sample-api"
  name_pr         = "${local.name}-${random_string.suffix.result}"
  cluster_name    = local.name
  cluster_version = "1.22"
  region          = "us-east-2"

  tags = {
    Version    = "${local.cluster_version}"
    GithubRepo = "sample-api"
    GithubOrg  = "soinshane"
  }
}

data "aws_caller_identity" "current" {

}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.17.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  #enabled_cluster_log_types = local.cluster_log_types


  cluster_ip_family          = "ipv6"
  create_cni_ipv6_iam_policy = true
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      service_account_role_arn = module.eks.vpc_cni_irsa.iam_role_arn
    }
  }
  cluster_encryption_config = [{
     provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
 

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

 # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["t2.small"]

    # We are using the IRSA created below for permissions
    iam_role_attach_cni_policy = true #true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = aws_key_pair.this.key_name
        source_security_group_ids = [aws_security_group.remote_access.id]
      }
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t2.nano"]
      capacity_type        = "SPOT"
      disk_size            = 256
      force_update_version = true
      instance_types       = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
      labels = {
        GithubRepo = "sample-api"
        GithubOrg  = "soinshane"
      }

      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 75
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = aws_kms_key.ebs.arn
            delete_on_termination = true
          }
        }
      }
       create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]

      create_security_group          = true
      security_group_name            = "eks-managed-node-group-complete-example"
      security_group_use_name_prefix = false
      security_group_description     = "EKS managed node group complete example security group"
#      https://github.com/terraform-aws-modules/terraform-aws-eks/blob/9a99689cc13147f4afc426b34ba009875a28614e/examples/eks_managed_node_group/main.tf#L41
 



    }

  }
  tags = local.tags
  
  # eks_managed_node_group_defaults = {
  #   disk_size        = 2
  #   instance_types   = ["t2.nano"]
  #   root_volume_type = "gp2"

  #   # See https://github.com/aws/containers-roadmap/issues/1666 for more context
  #   iam_role_attach_cni_policy = false
  # }

  # eks_managed_node_groups = {
  #   default_node_group = {
  #     # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
  #     # so we need to disable it to use the default template provided by the AWS EKS managed node group service
  #     create_launch_template = false
  #     launch_template_name   = ""
  #     instance_types         = ["t2.nano"]
  #     root_volume_type       = "gp2"
  #     min_size               = 1
  #     max_size               = 2
  #     desired_size           = 1
  #     #   # Remote access cannot be specified with a launch template
  #     #   remote_access = {
  #     #     ec2_ssh_key               = module.aws_key_pair.this.key_name
  #     #     source_security_group_ids = [modeule.aws_security_group.remote_access.id]
  #     #   }
  #   }

  #   # default_node_group = {
  #   #   # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
  #   #   # so we need to disable it to use the default template provided by the AWS EKS managed node group service
  #   #   create_launch_template = false
  #   #   launch_template_name   = ""
  #   #   instance_types         = ["t2.nano"]
  #   #   root_volume_type       = "gp2"
  #   #   min_size               = 1
  #   #   max_size               = 2
  #   #   desired_size           = 1
  #   #   remote_access = {
  #   #     ec2_ssh_key               = aws_key_pair.this.key_name
  #   #     source_security_group_ids = [aws_security_group.remote_access.id]
  #   #   }
  #   # }

  #   data = [{
  #     type      = "cluster_encryption_config"
  #     name      = "eks-p"
  #     resources = ["secrets"]

  #   }]
  #   # data "aws_eks_cluster" "cluster" {
  #   #   name = module.eks.cluster_id
  #   # }
  # }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name             = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                          = "karpenter_controller"
  attach_karpenter_controller_policy = true
  karpenter_controller_cluster_ids        = [module.eks.cluster_id]
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["default"].iam_role_arn
  ]
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.node_additional.arn
  role       = each.value.iam_role_name
}
# data "aws_eks_cluster_auth" "cluster_auth" {
#   name = module.eks.cluster_id
# }

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id

}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]

    #         # - rolearn: ${module.eks_managed_node_group.iam_role_arn}
#         #     username: system:node:{{EC2PrivateDNSName}}
#         #     groups:
#         #       - system:bootstrappers
#         #       - system:nodes
#         #       - system:node-proxier
#         userRoles = {
#           rolearn  = "arn:aws:iam::{{data.aws_caller_identity.current.arn}}:user/{{data.aws_caller_identity.current.arn}}"
#           username = "terraform"
#           groups   = ["system:masters"]
#         }
#         userRoles = {
#           rolearn  = "arn:aws:iam::{{AccountId}}:user/terraform-user"
#           username = "terraform"
#           groups   = ["system:masters"]
#         }
  })
}

# locals {
#   #context_name = "kube-system"
#   #context_user = "aws-node"
#   kubeconfig = yamlencode({
#     medatapiVersion = "v1"
#     kind            = "Config"
#     current-context = "terraform"
#     contexts = [{
#       name = "terraform"
#       context = {
#         cluster = module.eks.cluster_id
#         user    = "terraform"
#       }
#     }]
#     users = [{
#       name            = "terraform"
#       namespace       = "kube-system"
#       userRoles = {

#         # - rolearn: ${module.eks_managed_node_group.iam_role_arn}
#         #     username: system:node:{{EC2PrivateDNSName}}
#         #     groups:
#         #       - system:bootstrappers
#         #       - system:nodes
#         #       - system:node-proxier
#         userRoles = {
#           rolearn  = "arn:aws:iam::{{data.aws_caller_identity.current.arn}}:user/{{data.aws_caller_identity.current.arn}}"
#           username = "terraform"
#           groups   = ["system:masters"]
#         }
#         userRoles = {
#           rolearn  = "arn:aws:iam::{{AccountId}}:user/terraform-user"
#           username = "terraform"
#           groups   = ["system:masters"]
#         }
#       }
#       }]
#     clusters = [{
#       name = module.eks.cluster_id
#       cluster = {
#         certificate-authority-data = module.eks.cluster_certificate_authority_data
#         server                     = module.eks.cluster_endpoint
#       }
#     }]
   
#     # users = [{
#     #   name = local.context_user
#     #   user = {
#     #     token = data.aws_eks_cluster_auth.token
#     #   }
#     # }]
#   })
# }

# resource "null_resource" "apply" {
#   triggers = {
#     kubeconfig = base64encode(local.kubeconfig)
#     cmd_patch  = <<-EOT
#       kubectl create configmap aws-auth -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
#       kubectl patch configmap/aws-auth --patch "${module.eks.aws_auth_configmap_yaml}" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
#     EOT
#   }

#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     environment = {
#       KUBECONFIG = self.triggers.kubeconfig
#     }
#     command = self.triggers.cmd_patch
#   }
# }

resource "null_resource" "patch" {
  triggers = {
    kubeconfig = base64encode(local.kubeconfig)
    cmd_patch  = "kubectl patch configmap/aws-auth --patch \"${module.eks.aws_auth_configmap_yaml}\" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_patch
  }
}

# resource "null_resource" "patch" {
#   triggers = {
#     kubeconfig = base64encode(local.kubeconfig)
#     cmd_patch  = "echo running config && kubectl patch configmap/aws-auth --patch \"${module.eks.aws_auth_configmap_yaml}\" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
#   }

#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     environment = {
#       KUBECONFIG = "$resource.triggers.kubeconfig"
#     }
#     command = "$resource.triggers.cmd_patch"
#   }
# }


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14"

  name = "sample-api-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true
  create_egress_only_igw          = true

  public_subnet_ipv6_prefixes  = [0, 1, 2]
  private_subnet_ipv6_prefixes = [3, 4, 5]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}

module "vpc_cni_irsa" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version               = "~> 4.12"
  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {

    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]

    }
  }

  tags = local.tags
}

resource "aws_security_group" "additional" {
  name   = "${local.name}-additional"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = local.tags
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_key" "ebs" {
  description             = "Customer managed key to encrypt EKS managed node group volumes"
  deletion_window_in_days = 7

  policy = data.aws_iam_policy_document.ebs.json
}

# This policy is required for the KMS key used for EKS root volumes, so the cluster is allowed to enc/dec/attach encrypted EBS volumes
data "aws_iam_policy_document" "ebs" {
  # Copy of default KMS policy that lets you manage it
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Required for EKS
  statement {
    sid = "Allow service-linked role use of the CMK"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    actions   = ["kms:CreateGrant"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

##LTBegin
resource "aws_launch_template" "external" {
  name_prefix            = "external-eks-ex-"
  description            = "EKS managed node group external launch template"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
  }

  # if you want to use a custom AMI
  # image_id      = var.ami_id

  # If you use a custom AMI, you need to supply via user-data, the bootstrap script as EKS DOESNT merge its managed user-data then
  # you can add more than the minimum code you see in the template, e.g. install SSM agent, see https://github.com/aws/containers-roadmap/issues/593#issuecomment-577181345
  # (optionally you can use https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config to render the script, example: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/997#issuecomment-705286151)
  # user_data = base64encode(data.template_file.launch_template_userdata.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = "external_lt"
      CustomTag = "Instance custom tag"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      CustomTag = "Volume custom tag"
    }
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = {
      CustomTag = "EKS example"
    }
  }

  tags = {
    CustomTag = "Launch template custom tag"
  }

  lifecycle {
    create_before_destroy = true
  }
}
##ENDLT

resource "tls_private_key" "this" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = local.name
  public_key = tls_private_key.this.public_key_openssh

  tags = local.tags
}

resource "aws_security_group" "remote_access" {
  name        = "${local.name}-remote-access"
  description = "Allow remote SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

resource "aws_iam_policy" "node_additional" {
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = local.tags
}

# data "aws_ami" "eks_default" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-v*"]
#   }
# }

instance_refresh_enabled = true


