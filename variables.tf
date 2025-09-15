variable "vpc-subnet" {
 type    = string
 default = "10.0.0.0/16"
}

variable "public-subnet1-id" {
 type    = string
 default = "10.0.1.0/24"
}

variable "public-subnet2-id" {
 type    = string
 default = "10.0.2.0/24"
}

variable "internet-cidr" {
 type    = string
 default = "0.0.0.0/0"
}

variable "amazon-linux-id" {
 type    = string
 default = "ami-0b09ffb6d8b58ca91"
}
