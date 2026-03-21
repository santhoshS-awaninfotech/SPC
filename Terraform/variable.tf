
variable "cloud" {
  description = "Target cloud provider"
  type        = string
}

#AWS

variable "region1" { type = string }
variable "region2" { type = string }
variable "region1_code" { type = string }
variable "region2_code" { type = string }

variable "backendvm_count_region1" { type = number }
variable "discvm_count_region1"    { type = number }

variable "backendvm_count_region2" { type = number }
variable "discvm_count_region2"    { type = number }

locals {
  region_settings = {
    (var.region1) = {
      backendvm_count = var.backendvm_count_region1
      discvm_count    = var.discvm_count_region1
      region_code     = var.region1_code
    }
    (var.region2) = {
      backendvm_count = var.backendvm_count_region2
      discvm_count    = var.discvm_count_region2
      region_code     = var.region2_code
    }
  }
}



variable "availability_zone" {
 type    = string
 default = "ap-south-1a"
}
variable "instance_type" {
 type    = string
 default = "t3.micro"
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

