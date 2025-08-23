output "service_id" {
  value = docker_container.redis.id
}

output "published_port" {
  value = var.published_port
}

output "user_credentials" {
  value = local.user
}