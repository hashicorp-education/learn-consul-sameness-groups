variable "dc1_token" {
  type = string
}

variable "dc1_address" {
  type = string
}

variable "dc1_peername" {
  type = string
  description = "name of the remote peer of dc1"
  default = "learn-consul-sameness-dc2-default"
}

variable "dc2_token" {
  type = string
}

variable "dc2_address" {
  type = string
}

variable "dc2_peername" {
  type = string
  description = "name of the remote peer of dc2"
  default = "learn-consul-sameness-dc1-default"
}

variable "dc2_certificateauthority" {
  type = string # base64 encoded
}
