<#
    02-create-ous.ps1
    Builds the OU (Organizational Unit) structure that will hold this
    lab's security groups and test user accounts, separate from AD's
    default containers. Run on DC01 — the only machine with the
    ActiveDirectory PowerShell module available by default.
#>

Import-Module ActiveDirectory

$domainDN = (Get-ADDomain).DistinguishedName   # e.g. "DC=lab,DC=local"

New-ADOrganizationalUnit -Name "FileServerLab" -Path $domainDN

New-ADOrganizationalUnit -Name "Groups" -Path "OU=FileServerLab,$domainDN"
New-ADOrganizationalUnit -Name "Users"  -Path "OU=FileServerLab,$domainDN"
