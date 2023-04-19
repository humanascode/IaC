Configuration ad_setup {

    param
    (
         [Parameter(Mandatory)]
         [String]$DomainName,
 
         [Parameter(Mandatory)]
         [System.Management.Automation.PSCredential]$Admincreds
 
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration 
    Import-DscResource -ModuleName xPendingReboot 
    Import-DscResource -ModuleName ActiveDirectoryDSC

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("$($DomainName)\$($Admincreds.UserName)", $Admincreds.Password)

    Node 'localhost'
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
        
        WindowsFeature ADRole
        {
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $True
            Ensure = "Present"
        }

        WindowsFeature RSAT
        {
            Name = "RSAT-ADDS"
            IncludeAllSubFeature = $True
            Ensure = "Present"
        }

          ADDomain FirstDS
          {
              DomainName = $DomainName
              Credential = $DomainCreds
              SafemodeAdministratorPassword = $DomainCreds
              DatabasePath = "C:\NTDS"
              LogPath = "C:\NTDS"
              SysvolPath = "C:\SYSVOL"
              DependsOn = '[WindowsFeature]ADRole';
          }

        WindowsFeature DNS
        {
             Ensure = "Present"
             Name = "DNS"
        }

          WindowsFeature DnsTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        xPendingReboot RebootAfterPromotion{
            Name = "RebootAfterPromotion"
            DependsOn = "[ADDomain]FirstDS"
        }
    }
}

# Install aditional DC

Configuration AditionalDC {

    param
    (
         [Parameter(Mandatory)]
         [String]$DomainName,
 
         [Parameter(Mandatory)]
         [System.Management.Automation.PSCredential]$Admincreds
 
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDSC
    Import-DscResource -ModuleName xPendingReboot 

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("$($DomainName)\$($Admincreds.UserName)", $Admincreds.Password)

    Node 'localhost'
    {

        LocalConfigurationManager
        {   
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'   
            RebootNodeIfNeeded = $true
        }
        
        WindowsFeature ADRole
        {
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $True
            Ensure = "Present"
        }

        WindowsFeature RSAT
        {
            Name = "RSAT-ADDS"
            IncludeAllSubFeature = $True
            Ensure = "Present"
        }

        script 'Renew'
        {
            GetScript            = { return $false}
            TestScript           = { return $false}
            SetScript            = 
                {
                    Invoke-Expression -Command "ipconfig /renew"
                }
            DependsOn = "[WindowsFeature]RSAT"
        }

        WaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            Credential= $DomainCreds
            WaitTimeout = 60
            RestartCount = 2
            DependsOn = "[script]Renew"
        }

        ADDomainController BDC
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "C:\NTDS"
            LogPath = "C:\NTDS"
            SysvolPath = "C:\SYSVOL"
            DependsOn = "[WaitForADDomain]DscForestWait"
            
        }

        xPendingReboot RebootAfterPromotion{
            Name = "RebootAfterPromotion"
            DependsOn = "[ADDomainController]BDC"
        }
    }
}


# Install RODC - xAD doesnt support RODC installation - currently just installing the tools

Configuration InstallRODC {

    param
    (
         [Parameter(Mandatory)]
         [String]$DomainName,
 
         [Parameter(Mandatory)]
         [System.Management.Automation.PSCredential]$Admincreds
 
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration 
    Import-DscResource -ModuleName ActiveDirectoryDSC
    Import-DscResource -ModuleName xPendingReboot 

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("$($DomainName)\$($Admincreds.UserName)", $Admincreds.Password)

    Node 'localhost'
    {

        LocalConfigurationManager
        {   
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'   
            RebootNodeIfNeeded = $true
        }
        
        WindowsFeature ADRole
        {
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $True
            Ensure = "Present"
        }

        WindowsFeature RSAT
        {
            Name = "RSAT-ADDS"
            IncludeAllSubFeature = $True
            Ensure = "Present"
        }

        WaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            Credential= $DomainCreds
            WaitTimeout = 60
            RestartCount = 2
            DependsOn = "[WindowsFeature]ADRole"
        }

        ADDomainController BDC
        {
            DomainName = $DomainName
            Credential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            ReadOnlyReplica = $true
            DatabasePath = "C:\Windows\NTDS"
            LogPath = "C:\Windows\NTDS"
            SysvolPath = "C:\Windows\SYSVOL"
            DependsOn = "[WaitForADDomain]DscForestWait"
            
        }


        xPendingReboot RebootAfterPromotion{
            Name = "RebootAfterPromotion"
            DependsOn = "[ADDomainController]BDC"
        }
    }
}



#  Domain Join member servers

Configuration DomainJoin
{
    param
    (
         [Parameter(Mandatory)]
         [String]$DomainName,
 
         [Parameter(Mandatory)]
         [System.Management.Automation.PSCredential]$Admincreds
 
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -Module xComputerManagement
    Import-DscResource -ModuleName xPendingReboot 

    Node 'localhost' 
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        script 'Renew'
        {
            GetScript            = { return $false}
            TestScript           = { return $false}
            SetScript            = 
                {
                    Invoke-Expression -Command "ipconfig /renew"
                }
        }
        xComputer JoinDomain
        {
            Name = 'localhost'
            DomainName = $DomainName
            Credential = $Admincreds
            DependsOn = '[script]Renew'
        }

        xPendingReboot RebootAfterPromotion
        {
            Name = "RebootAfterPromotion"
            DependsOn = "[xComputer]JoinDomain"
        }

    }
    
}

