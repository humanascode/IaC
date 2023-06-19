locals {
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
}


resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.sh.name
  location            = azurerm_resource_group.sh.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.rdsh_count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.sh.name
  location              = azurerm_resource_group.sh.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }

   identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_network_interface.avd_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "vmext_aadlogin" {
  count                      = var.rdsh_count
  auto_upgrade_minor_version = true
  name                       = "AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

settings = <<-SETTINGS
   {
    "configurationFunction" : "Configuration.ps1\\AddSessionHost",
    "modulesUrl":"https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
    "properties":{
        "UseAgentDownloadEndpoint":true,
        "aadJoin":true,
        "aadJoinPreview":false,
        "hostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}",
        "mdmId":"",
        "registrationInfoToken":"${local.registration_token}",
        "sessionHostConfigurationLastUpdateTime":""
        }
    }

SETTINGS

  depends_on = [
    azurerm_virtual_desktop_host_pool.hostpool
  ]
}



resource "azurerm_virtual_machine_extension" "fslogix" {

  count = var.rdsh_count
  name               = "vm-fslogix"
  virtual_machine_id = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher          = "Microsoft.Compute"
  type               = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    "commandToExecute": join("", ["powershell.exe -ExecutionPolicy Unrestricted -Command \"& {",
      "$fsLogixURL='https://aka.ms/fslogix_download';",
      "$installerFile='fslogix_download.zip';",
      "$LocalPath = 'C:\\windows\\temp';",
      "Invoke-WebRequest $fsLogixURL -OutFile $LocalPath\\$installerFile;",
      "Expand-Archive $LocalPath\\$installerFile -DestinationPath '$LocalPath\\fslogix';",
      "write-host 'AIB Customization: Download Fslogix installer finished';",
      "Start-Process -FilePath '$LocalPath\\fslogix\\x64\\Release\\FSLogixAppsSetup.exe' -ArgumentList '/install /quiet' -Wait -Passthru;",
      "$regPath = 'HKLM:\\SOFTWARE\\FSLogix\\Profiles';",
      "New-ItemProperty -Path $regPath -Name Enabled -PropertyType DWORD -Value 1 -Force;",
      "New-ItemProperty -Path $regPath -Name VHDLocations -PropertyType MultiString -Value '\\\\${var.storage_account_name}.file.core.windows.net\\\\${var.fileshare_name}' -Force",
      "}\""
    ])
  })
}