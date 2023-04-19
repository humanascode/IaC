Install-Module ActiveDirectoryDSC -Confirm:$false -Force
Install-Module xPendingReboot -Confirm:$false -Force
Install-Module xNetworking -Confirm:$false -Force
Install-Module xComputerManagement -Confirm:$false -Force
Install-Module NetworkingDsc -Confirm:$false -Force

# Creating the ZIP file for the DSC Configuration
Publish-AzVMDscConfiguration "DynamicLab/deploy-ADRole.ps1" -OutputArchivePath  "DynamicLab/DynamicLab-deploy-ADRole.zip" -force
$storageAccountName = '****'
$resourceGroupName = '****'
$dscZipFilePath = "DynamicLab/DynamicLab-deploy-ADRole.zip"

$StorageAccount = Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName
$Container = $StorageAccount | Get-AzStorageContainer dscscripts

$Container | Set-AzStorageBlobContent -File $dscZipFilePath -Force
