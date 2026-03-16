
variable "cloud" {
  description = "Target cloud provider"
  type        = string
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
