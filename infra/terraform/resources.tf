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