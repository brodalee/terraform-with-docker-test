output "superuser" {
  description = "Superuser Postgres (username + password)"
  value = {
    username = var.superuser_name
    password = random_password.superuser.result
  }
  sensitive = true
}

output "rw_users" {
  value = local.users_rw
  sensitive = true
}

output "r_users" {
  value = local.users_ro
  sensitive = true
}

output "service_id" {
  value = docker_container.mysql.id
}

output "published_port" {
  value = var.published_port
}