resource "azurerm_virtual_machine_extension" "dsc" {
  name                       = "ADSC"
  virtual_machine_id         = var.vm_id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.77"
  auto_upgrade_minor_version = true
  settings         = <<SETTINGS
        {
            "wmfVersion": "latest",
            "configuration": {
                "url": "${local.url}",
                "script": "Deploy-ADRole.ps1",
                "function": "ad_setup"
            },
            "configurationArguments": {
              "DomainName": "${var.domain_name}",
              "Admincreds":{
                "username":"${var.username}",
                "password":"${data.azurerm_key_vault_secret.vm_admin_password.value}"
              }
            }
        }
    SETTINGS
    #lifecycle {
    #  replace_triggered_by = [
    #    null_resource.trigger
    #  ]
    #}
}
#make dsc update force every time the time changes
#resource "null_resource" "trigger" {
#  triggers =   {
#    trigger = local.time
#  }
#}