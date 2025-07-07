resource "digitalocean_kubernetes_cluster" "mopic-k8s" {
  name    = "mopic-k8s"
  region  = "sgp1"
  version = "1.33.1-do.0"

  node_pool {
    name       = "mopic-k8s-node-pool"
    size       = "s-4vcpu-8gb-intel"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}
