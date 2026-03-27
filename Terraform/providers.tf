
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
  alias  = "reg1"
  region = var.region1
    default_tags {
    tags = {
      Project     = "SPC"
      Region      = "R1"
      Env         = "STG"
    }
  }
}

provider "aws" {
  alias  = "reg2"
  region = var.region2
    default_tags {
    tags = {
      Project     = "SPC"
      Region      = "R2"
      Env         = "POC"
    }
  }
}
