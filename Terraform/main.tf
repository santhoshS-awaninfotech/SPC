
module "aws_resources" {
  source = "./AWS"
  count  = var.cloud == "AWS" ? 1 : 0
}

module "azure_resources" {
  source = "./Azure"
  count  = var.cloud == "Azure" ? 1 : 0
}