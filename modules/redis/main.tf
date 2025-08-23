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

resource "random_password" "redis_password" {
  length   = 22
  special  = true
}

locals {
  user = {
    name: var.username,
    password: random_password.redis_password.result
  }
}

resource "docker_network" "redis" {
  name       = var.network_name
  driver     = "bridge"
  attachable = true

  lifecycle {
    ignore_changes  = [name]
    prevent_destroy = false
  }
}

resource "docker_volume" "redis" {
  name = var.volume_name

  lifecycle {
    ignore_changes = [name]
  }
}

resource "docker_container" "redis" {
  name  = var.service_name
  image = "redis:${var.image_tag}"

  networks_advanced {
    name = docker_network.redis.name
  }

  mounts {
    target = "/data"
    source = docker_volume.redis.name
    type   = "volume"
  }

  # TODO : add user and password

  ports {
    internal = 6379
    external = var.published_port
  }

  #memory = var.memory_bytes
  #cpus   = var.cpu_nano / 1000000000
}