variable "service_name" {
  description = "Service name"
  type = string
  default = "mariadb"
}

variable "image_tag" {
  description = "Image tag"
  type = string
  default = "12.0.2"
}

variable "published_port" {
  description = "Published port in ingress mode"
  type = number
  default = 3306
}

variable "database_name" {
  description = "Database name"
  type = string
}

variable "superuser_name" {
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
  description = "Volume name for MysqlData"
  type = string
}

variable "network_name" {
  description = "Network name"
  type = string
}