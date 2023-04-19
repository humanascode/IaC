$storageAccountName = '****'
$resourceGroupName = '****'
$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName).context
$sasToken = New-AzStorageAccountSASToken -Context $context -Service Blob -ResourceType Service,Container,Object -Permission r -ExpiryTime (Get-Date).AddMinutes(30)