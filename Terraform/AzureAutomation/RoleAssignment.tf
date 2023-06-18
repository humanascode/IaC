data "azurerm_storage_account" "statesa" {
  name = "satfstatepost"
  resource_group_name = "RG-tfstatepost"
}

resource "azurerm_role_assignment" "blob_owner" {
    scope = data.azurerm_storage_account.statesa.id
    role_definition_name = "Storage Blob Data Owner"
    principal_id = azurerm_automation_account.aa.identity[0].principal_id
}