<#
    01-join-domain.ps1
    Joins this machine to the lab.local domain. Requires the machine's
    DNS to already be pointed at DC01 (see main.tf's dns_servers) —
    otherwise it can't find the domain to join in the first place.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName,      # e.g. "lab.local"

    [Parameter(Mandatory = $true)]
    [string]$AdminUsername,   # domain admin username, e.g. "labadmin"

    [Parameter(Mandatory = $true)]
    [string]$AdminPassword
)

$securePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("$AdminUsername@$DomainName", $securePassword)

Add-Computer -DomainName $DomainName -Credential $credential -Restart -Force
