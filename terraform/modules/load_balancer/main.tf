resource "azurerm_public_ip" "public" {
  name                = var.public_ip_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "public" {
  name                = var.load_balancer_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = var.load_balancer_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public.id
  }

  depends_on = [
    azurerm_public_ip.public
  ]
}

resource "azurerm_lb_backend_address_pool" "public" {
  loadbalancer_id = azurerm_lb.public.id
  name            = "HRB-NLB-BACKEND"
}

resource "azurerm_lb_probe" "public" {
  loadbalancer_id = azurerm_lb.public.id
  name            = "HttpHealthProbe"
  port            = 80
}

resource "azurerm_lb_rule" "public" {
  loadbalancer_id                = azurerm_lb.public.id
  name                           = "HttpBalancingRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.load_balancer_frontend_ip_configuration_name

  depends_on = [
    azurerm_lb_probe.public,
    azurerm_lb_backend_address_pool.public
  ]
}