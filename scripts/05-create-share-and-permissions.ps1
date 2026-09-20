<#
    05-create-share-and-permissions.ps1
    Builds the shared folder on FS01 and locks it down using NTFS
    permissions granted to the groups from 03-create-groups.ps1.
    Share (SMB - Server Message Block) permissions are left wide open
    on purpose - since the "most restrictive wins" rule between NTFS
    and Share always applies, opening the Share side all the way
    means NTFS is the only thing actually doing access control.
#>

$rootPath    = "C:\CompanyData"
$financePath = "$rootPath\Finance"
$hrPath      = "$rootPath\HR"

New-Item -Path $rootPath    -ItemType Directory -Force | Out-Null
New-Item -Path $financePath -ItemType Directory -Force | Out-Null
New-Item -Path $hrPath      -ItemType Directory -Force | Out-Null

New-SmbShare -Name "CompanyData" -Path $rootPath -FullAccess "Everyone"

# Finance: strip inherited permissions, grant back only what's needed
icacls $financePath /inheritance:r
icacls $financePath /grant "SYSTEM:(F)"
icacls $financePath /grant "LAB\Domain Admins:(F)"
icacls $financePath /grant "LAB\GG-Finance-ReadOnly:(RX)"
icacls $financePath /grant "LAB\GG-Finance-Modify:(M)"

# HR: same pattern
icacls $hrPath /inheritance:r
icacls $hrPath /grant "SYSTEM:(F)"
icacls $hrPath /grant "LAB\Domain Admins:(F)"
icacls $hrPath /grant "LAB\GG-HR-ReadOnly:(RX)"
icacls $hrPath /grant "LAB\GG-HR-FullControl:(F)"
