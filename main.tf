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

###################################
###    EXAMPLE USING MYSQL      ###
###################################

module "mysql-docker" {
  source = "./modules/mysql"

  service_name = "mysql-docker"
  database_name  = "mysql"
  superuser_name = "docker"
  published_port = 33306

  users_rw = ["api", "writer"]
  users_r = ["reader"]

  cpu_nano = 1500000000 # 1.5 vCPU
  memory_bytes = 2147483648 # 2 GiB
  network_name = "mysql-docker"
  volume_name = "mysql-docker"
}

###################################
###    EXAMPLE USING MARIA      ###
###################################

module "mariadb-docker" {
  source = "./modules/mariadb"

  service_name = "mariadb-docker"
  database_name  = "mariadb"
  superuser_name = "docker"
  published_port = 33307

  users_rw = ["api", "writer"]
  users_r = ["reader"]

  cpu_nano = 1500000000 # 1.5 vCPU
  memory_bytes = 2147483648 # 2 GiB
  network_name = "mariadb-docker"
  volume_name = "mariadb-docker"
}

###################################
###    EXAMPLE USING REDIS      ###
###################################

module "redis-docker" {
  source = "./modules/redis"

  service_name = "redis-docker"
  username = "redisuser"
  published_port = 6379

  cpu_nano = 1500000000 # 1.5 vCPU
  memory_bytes = 2147483648 # 2 GiB
  network_name = "redis-docker"
  volume_name = "redis-docker"
}

###################################
###    EXAMPLE USING REDIS      ###
###################################

module "nginx-docker" {
  source = "./modules/nginx"

  service_name = "nginx-docker"

  cpu_nano = 1500000000 # 1.5 vCPU
  memory_bytes = 2147483648 # 2 GiB
  network_name = "nginx-docker"
  volume_name = "nginx-docker"
}