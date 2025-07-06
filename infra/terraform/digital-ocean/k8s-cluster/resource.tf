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

resource "digitalocean_volume" "mopic-volume" {
  region                  = "sgp1"
  name                    = "mopic-volume"
  size                    = 500
  initial_filesystem_type = "ext4"
  description             = "an example volume"
}
