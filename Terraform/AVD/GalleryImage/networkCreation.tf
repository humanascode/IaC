resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNet"
  address_space       = var.vnet_range
  location            = azurerm_resource_group.sh.location
  resource_group_name = azurerm_resource_group.sh.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_range
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-NSG"
  location            = azurerm_resource_group.sh.location
  resource_group_name = azurerm_resource_group.sh.name
  security_rule {
    name                       = "HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

