terraform {
  required_version = ">=1.0"

  backend "azurerm" {
    resource_group_name  = "RG-RnD-MAIN"
    storage_account_name = "stawan"
    container_name       = "sant"
    key                  = "terraform.tfstate"
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

