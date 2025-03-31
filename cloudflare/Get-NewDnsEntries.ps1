Write-Host "Change directory to root"

# Save the current location
$originalLocation = Get-Location

Set-Location (Split-Path -Path $PSScriptRoot -Parent)

$blueSlotPublicIp = $(terraform output -raw lb_public_ip_blue)
$greenSlotPublicIp = $(terraform output -raw lb_public_ip_green)

$dnsRecords = @{}

$dnsRecords["blue-slot.razumovsky.me"] = $blueSlotPublicIp
$dnsRecords["green-slot.razumovsky.me"] = $greenSlotPublicIp

Set-Location $originalLocation

return $dnsRecords
