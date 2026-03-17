
terraform {
  required_version = ">=1.0"

  backend "azurerm" {
    resource_group_name  = "RG-RnD-MAIN"
    storage_account_name = "stawan"
    container_name       = "sant"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "aws" {
  region = var.region
}

module "aws_resources" {
  source             = "./AWS"
  count              = var.cloud == "AWS" ? 1 : 0
  cloud              = var.cloud
  vpc_cidr           = var.vpc_cidr
  backsubnet_cidr    = var.backsubnet_cidr
  discsubnet_cidr    = var.discsubnet_cidr
  region             = var.region
  discvm_count       = var.discvm_count
  backendvm_count    = var.backendvm_count
  disc_instance_type = var.disc_instance_type
  be_instance_type   = var.be_instance_type
  pgsql_password     = var.pgsql_password
  admin_password     = var.admin_password
  userA_password     = var.userA_password
  userB_password     = var.userB_password
}

module "azure_resources" {
  source         = "./Azure"
  count          = var.cloud == "Azure" ? 1 : 0
  cloud          = var.cloud
  pgsql_password = var.pgsql_password
  admin_password = var.admin_password
  userA_password = var.userA_password
  userB_password = var.userB_password
}