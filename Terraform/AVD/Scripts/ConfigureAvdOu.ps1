# Get the domain DN
$domainDN = (Get-ADRootDSE).defaultNamingContext

# Create an OU for the AVD Session Hosts
$ou = New-ADOrganizationalUnit -name "ouname" -Path $domainDN -PassThru

# Create a nsew user for joining Session hosts to the domain
$User = New-ADUser -Name "adjoin" -Path $ou.DistinguishedName -AccountPassword ("ChangeMe-123" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -PassThru

# The last part of this script gets grants the "Create Computer Objects" to the new user on the session host OU

$userSID = New-Object System.Security.Principal.SecurityIdentifier $user.SID
    
# Create AD rights for create child
$adRights = [System.DirectoryServices.ActiveDirectoryRights]::CreateChild

# Specify the type of access control (Allow)
$type = [System.Security.AccessControl.AccessControlType]::Allow

# Create a new rule (ACE)
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($userSID, $adRights, $type, [GUID]'bf967a86-0de6-11d0-a285-00aa003049e2')

# Get the OU where you want to apply the ACE
$ou = [ADSI]"LDAP://$($ou.DistinguishedName)"

# Apply the ACE to the OU's security
$ou.psbase.ObjectSecurity.AddAccessRule($ace)

# Commit the changes
$ou.psbase.CommitChanges()
