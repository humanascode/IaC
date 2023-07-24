$Applications = Get-MgApplication

$Logs = @()

$Days = 400
$now = get-date

foreach ($app in $Applications) {
    
    
    $AppName = $app.DisplayName
    $AppID = $app.Id
    $ApplID = $app.AppId
    $AppCreds = Get-MgApplication -ApplicationId $AppID | select PasswordCredentials, KeyCredentials
    $secret = $AppCreds.PasswordCredentials
    $cert = $AppCreds.KeyCredentials


    foreach ($s in $secret) {


        $StartDate = $s.StartDateTime
        $EndDate = $s.EndDateTime
        $operation = $EndDate - $now
        $ODays = $operation.Days

        if ($ODays -le $Days) {

            $Owner = Get-MgApplicationOwner -ApplicationId $app.Id
            $Username = $Owner.AdditionalProperties.UserPrincipalName -join ";"
            $OwnerID = $Owner.Id -join ";"
            if ($owner.AdditionalProperties.userPrincipalName -eq $Null) {
                $Username = $Owner.AdditionalProperties.displayName + " **<This is an Application>**"
            }
            if ($Owner.AdditionalProperties.displayName -eq $null) {
                $Username = "<<No Owner>>"
            }

            $Log = New-Object System.Object

            $Log | Add-Member -MemberType NoteProperty -Name "ApplicationName" -Value $AppName
            $Log | Add-Member -MemberType NoteProperty -Name "ApplicationID" -Value $ApplID
            $Log | Add-Member -MemberType NoteProperty -Name "Secret Start Date" -Value $StartDate
            $Log | Add-Member -MemberType NoteProperty -Name "Secret End Date" -value $EndDate
            $Log | Add-Member -MemberType NoteProperty -Name "Certificate Start Date" -Value $Null
            $Log | Add-Member -MemberType NoteProperty -Name "Certificate End Date" -value $Null
            $Log | Add-Member -MemberType NoteProperty -Name "Owner" -Value $Username
            $Log | Add-Member -MemberType NoteProperty -Name "Owner_ObjectID" -value $OwnerID

            $Logs += $Log
        }
    }

    foreach ($c in $cert) {
        $CStartDate = $c.StartDateTime
        $CEndDate = $c.EndDateTime
        $COperation = $CEndDate - $now
        $CODays = $COperation.Days

        if ($CODays -le $Days -and $CODays -ge 0) {

            $Owner = Get-MgApplicationOwner -ApplicationId $app.Id
            $Username = $Owner.AdditionalProperties.userPrincipalName -join ";"
            $OwnerID = $Owner.Id -join ";"
            if ($owner.AdditionalProperties.userPrincipalName -eq $Null) {
                $Username = $Owner.AdditionalProperties.displayName + " **<This is an Application>**"
            }
            if ($Owner.DisplayName -eq $null) {
                $Username = "<<No Owner>>"
            }

            $Log = New-Object System.Object

            $Log | Add-Member -MemberType NoteProperty -Name "ApplicationName" -Value $AppName
            $Log | Add-Member -MemberType NoteProperty -Name "ApplicationID" -Value $ApplID
            $Log | Add-Member -MemberType NoteProperty -Name "Certificate Start Date" -Value $CStartDate
            $Log | Add-Member -MemberType NoteProperty -Name "Certificate End Date" -value $CEndDate
            $Log | Add-Member -MemberType NoteProperty -Name "Owner" -Value $Username
            $Log | Add-Member -MemberType NoteProperty -Name "Owner_ObjectID" -value $OwnerID

            $Logs += $Log
        }
    }
}

$Logs