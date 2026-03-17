
variable "cloud" {
  description = "Target cloud provider"
  type        = string
}

#AWS
variable "region" {
 type    = string
 default = ""
}
variable "availability_zone" {
 type    = string
 default = "ap-south-1a"
}
variable "instance_type" {
 type    = string
 default = "t3.micro"
}

variable "subnet_cidrs" {
  type    = list(string)
}

variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "backsubnet_cidr" {
  type    = string
  default = ""
}

variable "discsubnet_cidr" {
  type    = string
  default = ""
}

variable "discvm_count" {
 type    = number
 default = 1
}
variable "backendvm_count" {
 type    = number
 default = 1
}
variable "disc_instance_type" {
 type    = string
 default = "t3.micro"
}
variable "be_instance_type" {
 type    = string
 default = "t3.micro"
}



#Azure
variable "location" {
  type    = string
  default = "westus2"
}
variable "common_tags" {
  type = map(string)
  default = {
    Environment = "DEV"
    Owner       = "UserA"
  }
}

#VM
variable "admin_password" {
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

