// EKS Resource

resource "aws_eks_cluster" "mopic_k8s" {
  name = "mopic_k8s"

  access_config {
    authentication_mode = "API"
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

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.mopic_k8s_cluster_AmazonEKSNetworkingPolicy,
  ]
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

resource "aws_eks_identity_provider_config" "mopic_k8s_identity_provider_config" {
  cluster_name = aws_eks_cluster.mopic_k8s.name

  oidc {
    client_id                     = "sts.amazonaws.com"
    issuer_url                    = aws_eks_cluster.mopic_k8s.identity.0.oidc.0.issuer
    identity_provider_config_name = "mopic_k8s_identity_provider_config"
  }
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

// S3 Resource

resource "aws_s3_bucket" "mopic_media" {
  bucket = "mopic_media"
}

resource "aws_iam_role" "mopic_media_manager" {
  name = "mopic_media_manager"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id
          }}:${aws_eks_cluster.mopic_k8s.identity.0.oidc.0.issuer}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${aws_eks_cluster.mopic_k8s.identity.0.oidc.0.issuer}:sub" : "system:serviceaccount:kube-system:s3-csi-driver-sa",
            "${aws_eks_cluster.mopic_k8s.identity.0.oidc.0.issuer}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "mopic_media_bucket_policy" {
  name = "mopic_media_bucket_policy"
  role = aws_iam_role.mopic_media_manager.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "MountpointFullBucketAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.mopic_media.id}"
        ]
      },
      {
        "Sid" : "MountpointFullObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.mopic_media.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mopic_media_manager_role_attach" {
  role       = aws_iam_role.mopic_media_manager.name
  policy_arn = aws_iam_role_policy.mopic_media_bucket_policy.id
}

resource "aws_eks_addon" "mopic_k8s_s3_csi_driver" {
  cluster_name = aws_eks_cluster.mopic_k8s.name
  addon_name   = "aws-mountpoint-s3-csi-driver"
}
