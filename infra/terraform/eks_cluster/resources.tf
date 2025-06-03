// EKS Resource

resource "aws_eks_cluster" "mopic_k8s" {
  name = "mopic_k8s"

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.mopic_k8s_cluster.arn
  version  = "1.32"

  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.mopic_k8s_node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = data.aws_subnets.default_subnets.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSNetworkingPolicy,
  ]
}

# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = aws_eks_cluster.mopic_k8s.name
#   addon_name   = "vpc-cni"
# }

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.mopic_k8s.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.mopic_k8s.name
  addon_name   = "coredns"
}


resource "aws_iam_role" "mopic_k8s_node" {
  name = "mopic_k8s_node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd40f86"] # Default thumbprint for EKS OIDC

  url = aws_eks_cluster.mopic_k8s.identity[0].oidc[0].issuer
}

resource "aws_iam_role_policy_attachment" "mopic_k8s_node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.mopic_k8s_node.name
}

resource "aws_iam_role_policy_attachment" "mopic_k8s_node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.mopic_k8s_node.name
}

resource "aws_iam_role" "mopic_k8s_cluster" {
  name = "mopic_k8s_cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mopic_k8s_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.mopic_k8s_cluster.name
}

resource "aws_iam_role_policy_attachment" "mopic_k8s_cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.mopic_k8s_cluster.name
}

resource "aws_iam_role_policy_attachment" "mopic_k8s_cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.mopic_k8s_cluster.name
}

resource "aws_iam_role_policy_attachment" "mopic_k8s_cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.mopic_k8s_cluster.name
}

resource "aws_iam_role_policy_attachment" "mopic_k8s_cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.mopic_k8s_cluster.name
}

// EBS Role Resource

resource "aws_iam_role" "mopic_media_manager" {
  name = "mopic_media_manager"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.eks.arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(aws_eks_cluster.mopic_k8s.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa",
            "${replace(aws_eks_cluster.mopic_k8s.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_iam_openid_connect_provider.eks
  ]
}

resource "aws_iam_role_policy_attachment" "mopic_media_manager_role_attach" {
  role       = aws_iam_role.mopic_media_manager.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# resource "aws_eks_addon" "mopic_k8s_ebs_csi_driver" {
#   cluster_name             = aws_eks_cluster.mopic_k8s.name
#   addon_name               = "aws-ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.mopic_media_manager.arn
# }

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = yamlencode([
      {
        userarn  = data.aws_caller_identity.current.arn
        username = data.aws_caller_identity.current.arn
        groups   = ["system:masters"]
      }
    ])
  }
}

resource "aws_iam_policy" "mopic_alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "./"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("load_balancer_controller_policy.json")
}

resource "aws_iam_role" "mopic_alb_controller" {
  name = "eks-alb-controller-role"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.eks.arn}",
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(aws_eks_cluster.mopic_k8s.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller",
            "${replace(aws_eks_cluster.mopic_k8s.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  policy_arn = aws_iam_policy.mopic_alb_controller.arn
  role       = aws_iam_role.mopic_alb_controller.name
}

