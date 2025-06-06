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

# data "aws_ssm_parameter" "eks_gpu_ami" {
#   name = "/aws/service/eks/optimized-ami/1.32/amazon-linux-2-gpu/recommended/image_id"
# }

# data "aws_ami" "eks_gpu" {
#   owners = ["602401143452"] # Amazon EKS
#   filter {
#     name   = "image-id"
#     values = [data.aws_ssm_parameter.eks_gpu_ami.value]
#   }
# }
