Set-Location $PSScriptRoot

$ErrorActionPreference = "Stop"

$scpCommand = $( terraform output -raw "scp_command_green" )

Write-Host "SCP command is: $scpCommand"

Write-Host "Executing $scpCommand"

Invoke-Expression $scpCommand

$copyCommand = $( terraform output -raw "copy_command_green" )

Write-Host "Copy command is: $copyCommand"

Write-Host "Executing command: $copyCommand"

Invoke-Expression $copyCommand

Write-Host "Green page deployed successfully!" -ForegroundColor Green

exit 0
