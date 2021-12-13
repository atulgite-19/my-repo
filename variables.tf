variable "region" {
	default = "ap-south-1"
}

variable "access_key" {
	default = "abcd"
}

variable "secret_key" {
	default = "abcd-xyz"
}

variable "name" {
  type        = string
  default     = "NetSPI"
}

variable "cidr_vpc" {
	default = "172.16.0.0/16"
}

variable "cidr_subnet" {
	default = "172.16.10.0/24"
}

variable "az1" {
	default = "ap-south-1a"
}

variable "encrypted" {
  default     = true
  type        = bool
}