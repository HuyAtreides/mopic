provider "kubernetes" {
  host                   = data.aws_eks_cluster.mopic_k8s.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.mopic_k8s.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.mopic_k8s.token
}
