variable "service_name" {
  description = "Service name"
  type = string
  default = "redis"
}

variable "image_tag" {
  description = "Image tag"
  type = string
  default = "1.29.1"
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
  description = "Volume name for Redis data"
  type = string
}

variable "network_name" {
  description = "Network name"
  type = string
}