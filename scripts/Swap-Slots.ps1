$prefix = "d01"
$blueBackendPoolName = "backend-pool-blue-$prefix"
$greenBackendPoolName = "backend-pool-green-$prefix"
$blueRuleName = "lb-rule-blue-$prefix"
$rgName = "rg-load-balancer-$prefix"

$loadBalancerRules = $( az network lb rule list --lb-name "lb-$prefix" `
    --resource-group "rg-load-balancer-$prefix" ) | ConvertFrom-Json

$blueRuleObject = $loadBalancerRules | Where-Object { $_.name -eq $blueRuleName }

if (!($blueRuleObject))
{
    Write-Host "Blue rule object not found, skipping..." -BackgroundColor Red
    exit 1
}

Write-Host "Object found $( $blueRuleObject.name )"

$currentBackendPool = $blueRuleObject.backendAddressPool.id

Write-Host "Current backend pool: $currentBackendPool"

if ($currentBackendPool -match $blueBackendPoolName)
{
    Write-Host "Blue rule targets $blueBackendPoolName"

    Write-Host "Swapping blue rule to point to green"

    az network lb rule update --lb-name "lb-$prefix" `
    --name $blueRuleName `
    --resource-group $rgName `
    --backend-pool-name $greenBackendPoolName

    exit 0
}

if ($currentBackendPool -match $greenBackendPoolName)
{
    Write-Host "Blue rule targets $greenBackendPoolName"

    Write-Host "Swapping blue rule to point to blue"

    az network lb rule update --lb-name "lb-$prefix" `
    --name $blueRuleName `
    --resource-group $rgName `
    --backend-pool-name $blueBackendPoolName

    exit 0
}
