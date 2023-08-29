resource "azurerm_lb_probe" "blue_ssh_probe" {
  loadbalancer_id = module.lb.id
  name            = "blue-ssh-probe"
  port            = 22

  depends_on = [
    module.lb
  ]
}

resource "azurerm_lb_rule" "blue_ssh_rule" {
  loadbalancer_id                = module.lb.id
  name                           = "blue-ssh-rule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = module.lb.frontend_ip_configuration_name
  backend_address_pool_ids       = [module.lb.blue_lb_pool_id]
  probe_id                       = azurerm_lb_probe.blue_ssh_probe.id

  depends_on = [
    azurerm_lb_probe.blue_ssh_probe,
    module.lb
  ]
}

resource "azurerm_lb_probe" "green_ssh_probe" {
  loadbalancer_id = module.lb.id
  name            = "green-ssh-probe"
  port            = 23

  depends_on = [
    module.lb
  ]
}

resource "azurerm_lb_rule" "green_ssh_rule" {
  loadbalancer_id                = module.lb.id
  name                           = "green-ssh-rule"
  protocol                       = "Tcp"
  frontend_port                  = 23
  backend_port                   = 22
  frontend_ip_configuration_name = module.lb.frontend_ip_configuration_name
  backend_address_pool_ids       = [module.lb.green_lb_pool_id]
  probe_id                       = azurerm_lb_probe.green_ssh_probe.id

  depends_on = [
    azurerm_lb_probe.green_ssh_probe,
    module.lb
  ]
}

resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = module.lb.id
  name            = "http-probe"
  port            = 80

  depends_on = [
    module.lb
  ]
}

resource "azurerm_lb_rule" "http_rule" {
  loadbalancer_id                = module.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = module.lb.frontend_ip_configuration_name
  backend_address_pool_ids       = [module.lb.blue_lb_pool_id]
  probe_id                       = azurerm_lb_probe.http_probe.id

  depends_on = [
    azurerm_lb_probe.http_probe,
    module.lb
  ]
}