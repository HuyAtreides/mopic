variable "default_vpc_id" {
  type    = string
  default = "vpc-05c60c9c7384cfac9"
}

variable "aws_default_region" {
  default = "eu-north-1"
}

variable "eks_eligible_default_az" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}
