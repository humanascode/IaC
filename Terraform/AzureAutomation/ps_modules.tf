# PowerShell Modules

resource "azurerm_automation_module" "msGraphAuthModule" {
  name = "Microsoft.Graph.Authentication"
  automation_account_name = azurerm_automation_account.aa.name
  resource_group_name = azurerm_resource_group.rg.name
  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/microsoft.graph.authentication.1.27.0.nupkg"
  }
}

resource "azurerm_automation_module" "msGraphModule" {
  name = "Microsoft.Graph.Users"
  automation_account_name = azurerm_automation_account.aa.name
  resource_group_name = azurerm_resource_group.rg.name
  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/microsoft.graph.users.1.27.0.nupkg"
  }
  depends_on = [
    azurerm_automation_module.msGraphAuthModule
  ]
}