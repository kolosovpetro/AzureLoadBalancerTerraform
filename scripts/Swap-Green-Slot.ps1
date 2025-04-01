param(
    [String] $prefix = "d01"
)

Write-Host "Swapping blue rule to point to green"

az network lb rule update --lb-name "lb-$prefix" `
    --name "http-rule-blue-$prefix" `
    --resource-group "rg-loadbalancer-$prefix" `
    --backend-pool-name "backend-pool-green-$prefix"
