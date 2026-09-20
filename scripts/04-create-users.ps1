<#
    04-create-users.ps1
    Creates test user accounts and adds each one to the group(s) that
    determine their effective NTFS permissions later. Brian is
    deliberately placed in two Finance groups at once — the
    cumulative-Allow case: no Deny involved, so his effective access
    becomes the union of both groups' rights.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserPassword
)

Import-Module ActiveDirectory

$usersOU = "OU=Users,OU=FileServerLab,DC=lab,DC=local"
$securePassword = ConvertTo-SecureString $UserPassword -AsPlainText -Force

$users = @(
    @{ Name = "Alice Finance"; SamAccountName = "alice.finance"; Groups = @("GG-Finance-ReadOnly") },
    @{ Name = "Brian Finance"; SamAccountName = "brian.finance"; Groups = @("GG-Finance-ReadOnly", "GG-Finance-Modify") },
    @{ Name = "Carla HR";      SamAccountName = "carla.hr";      Groups = @("GG-HR-ReadOnly") },
    @{ Name = "David HR";      SamAccountName = "david.hr";      Groups = @("GG-HR-FullControl") }
)

foreach ($user in $users) {
    New-ADUser `
        -Name $user.Name `
        -SamAccountName $user.SamAccountName `
        -UserPrincipalName "$($user.SamAccountName)@lab.local" `
        -Path $usersOU `
        -AccountPassword $securePassword `
        -Enabled $true `
        -ChangePasswordAtLogon $false

    foreach ($groupName in $user.Groups) {
        Add-ADGroupMember -Identity $groupName -Members $user.SamAccountName
    }
}
