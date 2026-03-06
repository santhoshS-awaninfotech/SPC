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

#variable "rg_count" {
#  type    = number
#  default = 3
#}

variable "ADMIN_PASSWORD" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}
