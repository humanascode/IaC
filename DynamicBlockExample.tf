terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
    features {}
}

locals {
  location = "westeurope"
}

variable "security_rules" {
  type = list(object({
   name                         = string
   priority                     = string
   direction                    = string
   access                       = string
   protocol                     = string
   source_port_range            = string
   destination_port_range       = string
   source_address_prefix        = string
   destination_address_prefix   = string
  }))
}

resource "azurerm_resource_group" "rg" {
  name = "RG-TF-DynamicBlockTest2"
  location = local.location
}

resource "azurerm_network_security_group" "nsg" {
    name = "nsg1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    dynamic "security_rule" {
      for_each =  var.security_rules
#      iterator = "secrule"
# The iterator argument (optional) sets the name of a temporary variable that represents the current element of the complex value. If omitted, the name of the variable defaults to the label of the dynamic block ("setting" in the example above).
      content {
            name                         = security_rule.value["name"]
            priority                     = security_rule.value["priority"]
            direction                    = security_rule.value["direction"]
            access                       = security_rule.value["access"]
            protocol                     = security_rule.value["protocol"]
            source_port_range            = security_rule.value["source_port_range"]
            destination_port_range       = security_rule.value["destination_port_range"]
            source_address_prefix        = security_rule.value["source_address_prefix"]
            destination_address_prefix   = security_rule.value["destination_address_prefix"]
      }     
    }
}