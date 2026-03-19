resource "tls_private_key" "tpk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "akp" {
  key_name   = "sant-ec2-key"
  public_key = tls_private_key.tpk.public_key_openssh
}

resource "azurerm_storage_blob" "ec2_private_key" {
  name                   = "sant-ec2-key${var.region}.pem"
  storage_account_name   = "stawan"
  storage_container_name = "sant"
  type                   = "Block"
  source_content         = tls_private_key.tpk.private_key_pem

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [source_content]
  }
}