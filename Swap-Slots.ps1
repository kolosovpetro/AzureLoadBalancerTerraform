$prefix = "d01"
$blueBackendPoolName = "backend-pool-blue-$prefix"
$greenBackendPoolName = "backend-pool-green-$prefix"
$blueRuleName = "lb-rule-blue-$prefix"
$greenRuleName = "lb-rule-green-$prefix"
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

$currentBlueBackendPool = $blueRuleObject.backendAddressPool.id

Write-Host "Current backend pool: $currentBlueBackendPool"

if ($currentBlueBackendPool -match $blueBackendPoolName)
{
    Write-Host "Blue rule targets $blueBackendPoolName"

    Write-Host "Deleting green rule..." -ForegroundColor Yellow

    az network lb rule delete `
        --resource-group $rgName `
        --lb-name "lb-$prefix" `
        --name $greenRuleName

    Write-Host "Swapping blue rule -> green" -ForegroundColor Green

    az network lb rule update --lb-name "lb-$prefix" `
    --name $blueRuleName `
    --resource-group $rgName `
    --backend-pool-name $greenBackendPoolName

    Write-Host "Creating green rule -> blue" -ForegroundColor Green

    az network lb rule create `
        --resource-group $rgName `
        --lb-name "lb-$prefix" `
        --name $greenRuleName `
        --protocol Tcp `
        --frontend-port 80 `
        --backend-port 80 `
        --frontend-ip-name "fipc-green-$prefix" `
        --backend-pool-name $blueBackendPoolName `
        --probe-name "lb-probe-green-$prefix" `
        --disable-outbound-snat true `
        --enable-tcp-reset false `
        --idle-timeout 4

    exit 0
}

if ($currentBlueBackendPool -match $greenBackendPoolName)
{
    Write-Host "Blue rule targets $greenBackendPoolName"

    Write-Host "Deleting green rule..." -ForegroundColor Yellow

    az network lb rule delete `
        --resource-group $rgName `
        --lb-name "lb-$prefix" `
        --name $greenRuleName

    Write-Host "Swapping blue rule -> blue" -ForegroundColor Green

    az network lb rule update --lb-name "lb-$prefix" `
        --name $blueRuleName `
        --resource-group $rgName `
        --backend-pool-name $blueBackendPoolName

    Write-Host "Creating green rule -> green" -ForegroundColor Green

    az network lb rule create `
        --resource-group $rgName `
        --lb-name "lb-$prefix" `
        --name $greenRuleName `
        --protocol Tcp `
        --frontend-port 80 `
        --backend-port 80 `
        --frontend-ip-name "fipc-green-$prefix" `
        --backend-pool-name $greenBackendPoolName `
        --probe-name "lb-probe-green-$prefix" `
        --disable-outbound-snat true `
        --enable-tcp-reset false `
        --idle-timeout 4

    exit 0
}
