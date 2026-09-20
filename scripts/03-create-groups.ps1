<#
    03-create-groups.ps1
    Creates the security groups this lab uses to control NTFS folder
    access. These live in the Groups OU built by 02-create-ous.ps1 —
    the NTFS ACL created by 05-create-share-and-permissions.ps1 grants
    permissions to these groups, never directly to individual users.
#>

Import-Module ActiveDirectory

$groupOU = "OU=Groups,OU=FileServerLab,DC=lab,DC=local"

$groups = @(
    "GG-Finance-ReadOnly",
    "GG-Finance-Modify",
    "GG-HR-ReadOnly",
    "GG-HR-FullControl"
)

foreach ($groupName in $groups) {
    New-ADGroup -Name $groupName -GroupScope Global -GroupCategory Security -Path $groupOU
}
