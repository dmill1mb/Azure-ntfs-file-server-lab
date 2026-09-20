<#
    00-promote-dc.ps1
    Promotes DC01 into a brand-new Active Directory forest, installing
    DNS as part of the same operation. This server has no domain to
    join yet — it's creating the very first one.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SafeModePassword,

    [string]$DomainName = "lab.local",
    [string]$DomainNetbiosName = "LAB"
)

$secureSafeModePassword = ConvertTo-SecureString $SafeModePassword -AsPlainText -Force

# Step 1: install the AD DS (Active Directory Domain Services) role itself —
# it doesn't exist on a fresh Windows Server until this runs.
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Step 2: load the promotion cmdlets — only available now that the feature above exists.
Import-Module ADDSDeployment

# Step 3: create the forest, the domain inside it, and install DNS in one operation.
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbiosName `
    -SafeModeAdministratorPassword $secureSafeModePassword `
    -InstallDns `
    -Force
