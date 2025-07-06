terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.digital_ocean_token
}

variable "digital_ocean_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
  default     = "" # Leave empty, or remove this line to force setting via env or CLI
}
