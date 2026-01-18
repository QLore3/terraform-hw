terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "docker" {
  host = "ssh://${var.ssh_user}@${var.vm_public_ip}:22"
}

variable "vm_public_ip" { type = string }
variable "ssh_user"     { type = string }

resource "random_password" "mysql_root" {
  length  = 16
  special = false
}

resource "random_password" "mysql_user" {
  length  = 16
  special = false
}

resource "docker_image" "mysql" {
  name         = "mysql:8"
  keep_locally = true
}

resource "docker_container" "mysql" {
  name  = "example_${random_password.mysql_user.result}"
  image = docker_image.mysql.image_id

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_user.result}",
    "MYSQL_ROOT_HOST=%",
  ]
}
