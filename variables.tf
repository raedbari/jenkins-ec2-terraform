variable "vpc_id" {
  type    = string
  default = "10.0.0.0/16"

}
variable "vpc_name" {
  type    = string
  default = "project_vpc"
}
variable "public_subnet_cidr" {
  type    = string
  default = "10.0.10.0/24"

}
variable "my_ip" {
  description = "my ip address"
  type        = string
  sensitive   = true
}
