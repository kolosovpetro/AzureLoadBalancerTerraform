resource "azurerm_lb_nat_rule" "blue_ssh" {
  name                           = "blue-slot-ssh-rule"
  resource_group_name            = azurerm_resource_group.public.name
  loadbalancer_id                = module.lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 22
  frontend_port_end              = 22
  backend_port                   = 22
  frontend_ip_configuration_name = module.lb.frontend_ip_configuration_name
  backend_address_pool_id        = module.lb.blue_lb_pool_id

  depends_on = [
    module.lb
  ]
}