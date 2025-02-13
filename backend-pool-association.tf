resource "azurerm_network_interface_backend_address_pool_association" "green_slot_lb_association" {
  for_each                = local.servers
  network_interface_id    = module.backend_machines[each.key].network_interface_id
  ip_configuration_name   = module.backend_machines[each.key].ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pools[each.key].id

  depends_on = [
    azurerm_lb.public,
    azurerm_lb_backend_address_pool.backend_pools,
    module.backend_machines
  ]
}
