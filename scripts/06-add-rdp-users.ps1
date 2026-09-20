<#
    06-add-rdp-users.ps1
    Grants the test users RDP (Remote Desktop Protocol) login rights
    on CLIENT01 by adding them to the local Remote Desktop Users
    group. Being a domain user with NTFS permissions on a share
    doesn't automatically mean you're allowed to log on to a machine
    remotely - that's a completely separate right.
#>

$rdpGroup = "Remote Desktop Users"
$users = @(
    "LAB\alice.finance",
    "LAB\brian.finance",
    "LAB\carla.hr",
    "LAB\david.hr"
)

foreach ($user in $users) {
    Add-LocalGroupMember -Group $rdpGroup -Member $user
}
