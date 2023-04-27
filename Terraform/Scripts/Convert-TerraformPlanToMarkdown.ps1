# desc: convert terraform plan to markdown table

terraform show -json demo4.tfplan > demo4.tfplan.json
$json = Get-Content .\demo4.tfplan.json -Raw

function ConvertTo-MarkdownTable {
    param (
        [Parameter(Mandatory=$true)][string] $JsonContent
    )

    $data = ConvertFrom-Json -InputObject $JsonContent
    $resources = $data.planned_values.root_module.resources
    $resourceChanges = $data.resource_changes | Group-Object -Property address

    $output = @()
    $output += "| Resource Address | Resource Type | Location | Name | Action | Property | Old Value | New Value |"
    $output += "|------------------|---------------|----------|------|--------|----------|-----------|-----------|"

    foreach ($resource in $resources) {
        $address = $resource.address
        $type = $resource.type
        $location = $resource.values.location
        $name = $resource.values.name
        $change = $resourceChanges | Where-Object { $_.Name -eq $address }
        $action = ($change.Group.change.actions -join ', ')

        $before = $change.Group.change.before | ConvertTo-Json
        $after = $change.Group.change.after | ConvertTo-Json

        $beforeObj = ConvertFrom-Json -InputObject $before
        $afterObj = ConvertFrom-Json -InputObject $after

        $propertyList = @()

        foreach ($property in ($beforeObj.PSObject.Properties.Name + $afterObj.PSObject.Properties.Name | Select-Object -Unique)) {
            $oldValue = $beforeObj.$property
            $newValue = $afterObj.$property

            if ($oldValue -ne $newValue) {
                $propertyList += @{
                    Property = $property
                    OldValue = $oldValue
                    NewValue = $newValue
                }
            }
        }

        if ($propertyList.Count -eq 0) {
            $output += "| $address | $type | $location | $name | $action | - | - | - |"
        } else {
            foreach ($propertyItem in $propertyList) {
                $property = $propertyItem.Property
                $oldValue = $propertyItem.OldValue
                $newValue = $propertyItem.NewValue

                $output += "| $address | $type | $location | $name | $action | $property | $oldValue | $newValue |"
            }
        }
    }

    $output -join "`n"
}

$table = ConvertTo-MarkdownTable -JsonContent $json
$table

$table | Out-File 111.md
