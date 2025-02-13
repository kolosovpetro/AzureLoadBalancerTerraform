resource "azurerm_lb_nat_rule" "ssh_nat_rules" {
  for_each                       = local.servers
  resource_group_name            = azurerm_resource_group.public.name
  loadbalancer_id                = azurerm_lb.public.id
  name                           = "${each.key}-ssh-nat"
  protocol                       = "Tcp"
  frontend_port                  = each.value.ssh_frontend_port
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.public.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_nat_rule_association" "ssh_nat_rule_association" {
  for_each              = local.servers
  network_interface_id  = module.backend_machines[each.key].network_interface_id
  ip_configuration_name = module.backend_machines[each.key].ip_configuration_name
  nat_rule_id           = azurerm_lb_nat_rule.ssh_nat_rules[each.key].id

  depends_on = [
    module.backend_machines,
    azurerm_lb_nat_rule.ssh_nat_rules
  ]
}
