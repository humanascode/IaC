# Connect with managed identity
Connect-AzAccount -Identity
# Define variables
$saName = "demostorageaccount"
$containerName = "state"
$fileName = "terraform.tfstate"
$blobsToKeep = 10
 
# Get storage context
$stg = New-AzStorageContext -StorageAccountName $saname -UseConnectedAccount
 
# Get blob versions
$blobVersions = Get-AzStorageBlob -Container $containerName -Context $stg -IncludeVersion | `
Where-Object {$_.Name -eq $fileName} | Sort-Object LastModified -Descending
 
# Delete old blob versions
if ($blobVersions.Count -gt $blobsToKeep)
{
    for ($i = $blobsToKeep; $i -lt $blobVersions.Count; $i++) {
        $blobVersions[$i] | Remove-AzStorageBlob
        Write-Output $i
    }
}