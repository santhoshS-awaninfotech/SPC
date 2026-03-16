
variable "cloud" {
  description = "Target cloud provider"
  type        = string
}

#AWS
variable "region" {
 type    = string
 default = "ap-south-1"
}

variable "availability_zone" {
 type    = string
 default = "ap-south-1a"
}

variable "instance_type" {
 type    = string
 default = "t3.micro"
}

#VM
variable "ADMIN_PASSWORD" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "userA_password" {
  type      = string
  sensitive = true
}
variable "userB_password" {
  type      = string
  sensitive = true
}
variable "pgsql_password" {
  type      = string
  sensitive = true
}
