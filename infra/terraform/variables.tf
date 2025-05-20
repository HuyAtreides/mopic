variable "default_vpc_id" {
  type = string
  default = "vpc-0ec02abf76ce202f5"
}

variable "eks_eligible_default_az" {
  type = list(string)
  default = [ "us-east-1d", "us-east-1b", "us-east-1c", "us-east-1f", "us-east-1a" ]
}