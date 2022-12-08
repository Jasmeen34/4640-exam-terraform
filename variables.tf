variable "do_token" {}

variable "region" {
  type    = string
  default = "sfo3"
}
variable "image" {
  type  = string
  default = "rockylinux-9-x64"
}
variable "ip_range" {
  type = string
  default = "10.46.40.0/24"
}
