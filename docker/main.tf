terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

###################################
###  EXAMPLE USING POSTGRESQL   ###
###################################

module "postgresql-docker" {
  source = "./modules/postgresql"

  service_name = "postgresql-docker"
  pg_database = "postgresql_docker"
  pg_superuser = "docker"
  published_port = 55432

  users_rw = ["api", "writer"]
  users_r = ["reader"]

  cpu_nano = 1500000000 # 1.5 vCPU
  memory_bytes = 2147483648 # 2 GiB
  network_name = "postgresql-docker"
  volume_name = "postgresql-docker"
}