terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "nginx" {
  name       = var.network_name
  driver     = "bridge"
  attachable = true

  lifecycle {
    ignore_changes  = [name]
    prevent_destroy = false
  }
}

resource "docker_volume" "nginx" {
  name = var.volume_name

  lifecycle {
    ignore_changes = [name]
  }
}

resource "docker_container" "nginx" {
  name  = var.service_name
  image = "nginx:${var.image_tag}"

  networks_advanced {
    name = docker_network.nginx.name
  }

  mounts {
    target = "/etc/nginx/conf.d"
    source = abspath("${path.module}/config")
    type   = "bind"
  }

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  #memory = var.memory_bytes
  #cpus   = var.cpu_nano / 1000000000
}