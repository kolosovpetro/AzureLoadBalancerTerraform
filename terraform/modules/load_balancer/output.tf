output "backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.public.id
}

output "frontend_ip_configuration_id" {
  value = azurerm_lb.public.frontend_ip_configuration[0].id
}