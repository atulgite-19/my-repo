
variable "region" {
	default = "ap-south-1"
}

variable "access_key" {
	default = "abcd"
}

variable "secret_key" {
	default = "abcd-xyz"
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

variable "private_ips" {
	default = "172.16.10.100"
}

variable "deletion_window" {
	default = "10"
}

variable "bucket_name" {
	default = "my-s3-bucket"
}

variable "acl" {
	default = "private"
}

variable "port_ingress" {
	default = "22"
}

variable "protocol_ingress" {
	default = "tcp"
}

variable "port_egress" {
	default = "0"
}

variable "protocol_egress" {
	default = "-1"
}

variable "cidr_egress" {
	default = "["0.0.0.0/0"]"
}

variable "instance_username" {
	default = "ec2-user"
}

variable "path_to_private_key" {
	default = "myprivatekey"
}

variable "path_to_public_key" {
	default = "myprivatekey.pub"
}

variable "connection_type" {
	default = "ssh"
}

# EIP provisioned using AWS Console
variable "eip" {
	default = "15.207.22.91"
}

variable "ami" {
	description = "Choose windows 2019 or 2016 image or linux image."
	default     = "2019"
}

variable "instance_type" {
	default = "t2.micro"
}

variable "keyname" {
	default = "mykey"
}
variable "default_ami" {

	type = map(any)
	default = {
		"linux" = {
			name = "*"
			ami_id = "ami-052cef05d01020f1d"
		},
		"2016" = {
			name = "WIN2016-CUSTOM*"
			ami_id = "*"
		},
		"2019" = {
			name = "WIN2019-CUSTOM*"
			ami_id = "*"
		}
	}
}