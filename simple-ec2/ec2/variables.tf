variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable "key_name" {
  type = string
}

variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
}

variable "ami" {
  type    = string
  default = "ami-074251216af698218"

}
