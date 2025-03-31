Set-Location -Path $PSScriptRoot

$zoneName = "razumovsky.me"

$newDnsEntriesHashtable = .\Get-NewDnsEntries.ps1

.\Upsert-CloudflareDnsRecord.ps1 `
    -ApiToken $env:CLOUDFLARE_API_KEY `
    -ZoneName $zoneName `
    -NewDnsEntriesHashtable $newDnsEntriesHashtable

Set-Location (Split-Path -Path $PSScriptRoot -Parent)
exit 0
