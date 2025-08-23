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

# Password generation
resource "random_password" "superuser" {
  length  = 24
  special = true
}

resource "random_password" "r" {
  for_each = toset([for u in var.users_r : replace(lower(u), "[^a-z0-9_.-]", "-")])
  length   = 22
  special  = true
}

resource "random_password" "rw" {
  for_each = toset([for u in var.users_rw : replace(lower(u), "[^a-z0-9_.-]", "-")])
  length   = 22
  special  = true
}

# Creating users data
locals {
  superuser = {
    name : replace(lower(var.superuser_name), "[^a-z0-9_.-]", "-"), password : random_password.superuser.result
  }
  users_rw  = [
    for u in var.users_rw :{ name : replace(lower(u), "[^a-z0-9_.-]", "-"), password : random_password.rw[u].result }
  ]
  users_ro  = [
    for u in var.users_r :{ name : replace(lower(u), "[^a-z0-9_.-]", "-"), password : random_password.r[u].result }
  ]
}

resource "docker_network" "mysql" {
  name       = var.network_name
  driver     = "bridge"
  attachable = true

  lifecycle {
    ignore_changes  = [name]
    prevent_destroy = false
  }
}

resource "docker_volume" "mysql" {
  name = var.volume_name

  lifecycle {
    ignore_changes = [name]
  }
}

locals {
  sql_ro_template = <<-EOT
    CREATE USER 'database_username'@'%' IDENTIFIED BY 'database_user_password';
    GRANT SELECT ON database_name.* TO 'database_username'@'%';
    FLUSH PRIVILEGES;
  EOT

  sql_rw_template = <<-EOT
    CREATE USER 'database_username'@'%' IDENTIFIED BY 'database_user_password';
    GRANT SELECT, INSERT, UPDATE, DELETE ON database_name.* TO 'database_username'@'%';
    FLUSH PRIVILEGES;
  EOT
}

resource "local_file" "users_ro_sql" {
  for_each = {for u in local.users_ro : u.name => u}

  filename = "${path.module}/generated/init/${each.key}-ro.sql"

  content = replace(
    replace(
      replace(
        local.sql_ro_template,
        "database_username",
        each.value.name
      ),
      "database_user_password",
      each.value.password
    ),
    "database_name",
    var.database_name
  )
}

resource "local_file" "users_rw_sql" {
  for_each = {for u in local.users_rw : u.name => u}

  filename = "${path.module}/generated/init/${each.key}-rw.sql"

  content = replace(
    replace(
      replace(
        local.sql_rw_template,
        "database_username",
        each.value.name
      ),
      "database_user_password",
      each.value.password
    ),
    "database_name",
    var.database_name
  )
}

resource "docker_container" "mysql" {
  name  = var.service_name
  image = "mysql:${var.image_tag}"

  networks_advanced {
    name = docker_network.mysql.name
  }

  mounts {
    target = "/var/lib/mysql"
    source = docker_volume.mysql.name
    type   = "volume"
  }

  mounts {
    target = "/docker-entrypoint-initdb.d"
    source = abspath("${path.module}/generated/init")
    type   = "bind"
  }

  env = [
    "MYSQL_DATABASE=${var.database_name}",
    "MYSQL_USER=${var.superuser_name}",
    "MYSQL_ROOT_PASSWORD=${random_password.superuser.result}",
    "MYSQL_PASSWORD=${random_password.superuser.result}",
  ]

  ports {
    internal = 3306
    external = var.published_port
  }

  #memory = var.memory_bytes
  #cpus   = var.cpu_nano / 1000000000
}