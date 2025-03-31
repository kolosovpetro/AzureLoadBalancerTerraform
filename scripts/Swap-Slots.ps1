# Set prefix
$prefix = "d01"

# List all rules
az network lb rule list --lb-name "lb-$prefix" `
    --resource-group "rg-loadbalancer-$prefix"

# Delete green rule
az network lb rule delete --lb-name "lb-$prefix" `
    --name "http-rule-green-$prefix" `
    --resource-group "rg-loadbalancer-$prefix"

# Update rule to point to green pool
az network lb rule update --lb-name "lb-$prefix" `
    --name "http-rule-blue-$prefix" `
    --resource-group "rg-loadbalancer-$prefix" `
    --backend-pool-name "green-pool"

# Update rule to point to blue pool
az network lb rule update --lb-name "lb-$prefix" `
    --name "http-rule-blue-$prefix" `
    --resource-group "rg-loadbalancer-$prefix" `
    --backend-pool-name "blue-pool"
