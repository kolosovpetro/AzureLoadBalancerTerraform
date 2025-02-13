resource "azurerm_lb_probe" "lb_http_probes" {
  for_each        = local.servers
  loadbalancer_id = azurerm_lb.public.id
  name            = "${each.key}-http-probe"
  port            = each.value.http_frontend_port
}

resource "azurerm_lb_rule" "http_lb_rules" {
  for_each                       = local.servers
  loadbalancer_id                = azurerm_lb.public.id
  name                           = "${each.key}-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = each.value.http_frontend_port
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.public.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb_http_probes[each.key].id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_pools[each.key].id]

  depends_on = [azurerm_lb_probe.lb_http_probes]
}
