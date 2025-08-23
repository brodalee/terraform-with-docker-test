variable "service_name" {
  description = "Service name"
  type = string
  default = "postgresql"
}

variable "image_tag" {
  description = "Image tag"
  type = string
  default = "17.6-alpine3.22"
}

variable "published_port" {
  description = "Published port in ingress mode"
  type = number
  default = 5432
}

variable "pg_database" {
  description = "Database name"
  type = string
}

variable "pg_superuser" {
  description = "User Admin"
  type = string
}

variable "users_rw" {
  description = "Users read&write"
  type = list(string)
  default = []
}

variable "users_r" {
  description = "Users read only"
  type = list(string)
  default = []
}

variable "cpu_nano" {
  description = "CPU limit in noneCPUs (1 CPU = 1e9)"
  type = number
  default = 1000000000 # 1 vCPU
}

variable "memory_bytes" {
  description = "Memory limit in bytes"
  type = number
  default = 1073741824 # 1 GiB
}

variable "volume_name" {
  description = "Volume name for PGDATA"
  type = string
}

variable "network_name" {
  description = "Network name"
  type = string
}