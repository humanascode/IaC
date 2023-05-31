# Description: This file contains the terraform code to create the automation account and the runbook

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = local.location
}

resource "azurerm_automation_account" "aa" {
    name = var.automation_account_name
    location = local.location
    resource_group_name = azurerm_resource_group.rg.name
    identity {
      type = "SystemAssigned"
    }
    sku_name = "Basic"
}

# Loading the runbook content from a local file

data "local_file" "ps_content" {
  filename = "DeleteOldBlobVersions.ps1"
}

resource "azurerm_automation_runbook" "ps" {
  name = "RemoveOldBlobVersions"
  location = azurerm_automation_account.aa.location
  resource_group_name = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  runbook_type = "PowerShell"

  content = data.local_file.ps_content.content
  log_progress = "true"
  log_verbose = "true"
}

# Creating a schedule to run the runbook daily at midnight. the start_time and expiry_time are calculated using the locals defined in locals.tf

resource "azurerm_automation_schedule" "schedule" {
  name = "daily"
  automation_account_name = azurerm_automation_account.aa.name
  resource_group_name = azurerm_automation_account.aa.resource_group_name
  frequency               = "Day"
  interval                = 1
  timezone                = local.time_zone
  start_time              = local.midnight
  expiry_time             = local.expiry_time
  description             = "Daily at midnight"
}

# Linking the schedule to the runbook

resource "azurerm_automation_job_schedule" "schedule_link" {
  resource_group_name     = azurerm_automation_account.aa.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  schedule_name           = azurerm_automation_schedule.schedule.name
  runbook_name            = azurerm_automation_runbook.ps.name
}