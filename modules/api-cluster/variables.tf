
variable "app_name" {
  type = string
}

variable "current_api" {
  type = string
  validation {
    condition     = can(regex("^system", "${var.current_api}")) || can(regex("^data", "${var.current_api}"))
    error_message = "The current_api needs to begin with system, or data."
  }
}

variable "docker_image" {
  type = string
  validation {
    condition     = can(regex("system$", "${var.docker_image}")) || can(regex("data$", "${var.docker_image}"))
    error_message = "The docker_image needs to end with system, or data."
  }
}
variable "docker_tag" {
  type = string
}
variable "docker_repo" {
  type = string
}

variable "replicas" {
  type = number
}

variable "name_space" {
  type = string
}
