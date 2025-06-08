variable "default_vpc_id" {
  type    = string
  default = "vpc-00bd235403b6ba4c7"
}

variable "aws_default_region" {
  default = "ap-southeast-1"
}

variable "eks_eligible_default_az" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}
