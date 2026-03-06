variable "location" {
  type    = string
  default = "eastus"
}

variable "common_tags" {
  type = map(string)
  default = {
    Environment = "DEV"
    Owner       = "UserA"
  }
}

variable "rg_count" {
  type    = number
  default = 3
}
