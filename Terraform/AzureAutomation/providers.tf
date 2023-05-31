
# Confiuring the Azure provider

provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3"
    }
  }
}