data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.default_vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = var.eks_eligible_default_az
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "mopic_k8s" {
  name = aws_eks_cluster.mopic_k8s.name
}

data "aws_eks_cluster_auth" "mopic_k8s" {
  name = data.aws_eks_cluster.mopic_k8s.name
}

data "aws_s3_bucket" "mopic_s3_bucket" {
  bucket = "mopic-media"
}
