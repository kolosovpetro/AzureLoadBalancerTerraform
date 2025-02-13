Set-Location $PSScriptRoot

$LbPublicIp = $( terraform output -raw "lb_public_ip" )

Write-Host "LB public IP: $LbPublicIp"

$userName = "razumovsky_r"
$port = 44
$TargetTempLocation = "/tmp/blue.html"
$SourceLocation = "./html/blue.html"

Write-Host "Make sure target folder TMP exists"

ssh -p $port $userName@$LbPublicIp "mkdir -p /tmp && sudo chmod 777 /tmp"

$ScpCommand = @"
scp -P `"$port`" `"$SourceLocation`" `"$userName@$LbPublicIp"`:`"$TargetTempLocation`"
"@

Write-Host "Scp Command: $ScpCommand"

Invoke-Expression $ScpCommand
