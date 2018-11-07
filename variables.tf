variable "access_key" {}
variable "secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "region" {
	default = "us-west-1"
}

variable "amis" {
	type 	= "map"
	default = {
		"us-west-1" = "ami-063aa838bd7631e0b"
		"us-east-1" = "ami-b374d5a5"
	}
}

variable "nat_amis" {
	type 	= "map"
	default = {
		"us-west-1" = "ami-0d4027d2cdbca669d"
	}
}

variable "vpc_cidr" {
	default = "10.0.0.0/16"
}

variable "subnet1_cidr" {
	default = "10.0.0.0/24"
}

variable "subnet2_cidr" {
	default = "10.0.1.0/24"
}
