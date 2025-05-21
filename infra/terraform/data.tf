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
