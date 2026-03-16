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