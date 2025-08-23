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
    name : replace(lower(var.pg_superuser), "[^a-z0-9_.-]", "-"), password : random_password.superuser.result
  }
  users_rw  = [
    for u in var.users_rw :{ name : replace(lower(u), "[^a-z0-9_.-]", "-"), password : random_password.rw[u].result }
  ]
  users_ro  = [
    for u in var.users_r :{ name : replace(lower(u), "[^a-z0-9_.-]", "-"), password : random_password.r[u].result }
  ]
}

resource "docker_network" "pg" {
  name       = var.network_name
  driver     = "bridge"
  attachable = true

  lifecycle {
    ignore_changes  = [name]
    prevent_destroy = false
  }
}

resource "docker_volume" "pg" {
  name = var.volume_name

  lifecycle {
    ignore_changes = [name]
  }
}

locals {
  sql_create_accesses_template = <<-EOT
    CREATE ROLE readaccess;
    CREATE ROLE readwriteaccess;
  EOT

  sql_ro_template = <<-EOT
    GRANT CONNECT ON DATABASE database_name TO readaccess;
    GRANT USAGE ON SCHEMA public TO readaccess;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
    CREATE USER database_username WITH PASSWORD 'database_user_password';
    GRANT readaccess TO database_username;
  EOT

  sql_rw_template = <<-EOT
    GRANT CONNECT ON DATABASE database_name TO readwriteaccess;
    GRANT USAGE, CREATE ON SCHEMA public TO readwriteaccess;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO readwriteaccess;
    CREATE USER database_username WITH PASSWORD 'database_user_password';
    GRANT readwriteaccess TO database_username;
  EOT
}

resource "local_file" "pg_accesses" {
  filename = "${path.module}/generated/init/__accesses.sql"
  content = local.sql_create_accesses_template
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
    var.pg_database
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
    var.pg_database
  )
}

resource "docker_container" "postgres" {
  name  = var.service_name
  image = "postgres:${var.image_tag}"

  networks_advanced {
    name = docker_network.pg.name
  }

  mounts {
    target = "/var/lib/postgresql/data"
    source = docker_volume.pg.name
    type   = "volume"
  }

  mounts {
    target = "/docker-entrypoint-initdb.d"
    source = abspath("${path.module}/generated/init")
    type   = "bind"
  }

  env = [
    "POSTGRES_DB=${var.pg_database}",
    "POSTGRES_USER=${var.pg_superuser}",
    "POSTGRES_PASSWORD=${random_password.superuser.result}",
  ]

  ports {
    internal = 5432
    external = var.published_port
  }

  #memory = var.memory_bytes
  #cpus   = var.cpu_nano / 1000000000
}