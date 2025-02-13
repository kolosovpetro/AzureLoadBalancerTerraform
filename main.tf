#################################################################################################################
# RESOURCE GROUP
#################################################################################################################

resource "azurerm_resource_group" "public" {
  location = var.resource_group_location
  name     = "rg-load-balancer-${var.prefix}"
}

#################################################################################################################
# VNET AND SUBNET
#################################################################################################################

resource "azurerm_virtual_network" "public" {
  name                = "vnet-${var.prefix}"
  address_space       = ["10.10.0.0/24"]
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
}

resource "azurerm_subnet" "internal" {
  name                 = "subnet-${var.prefix}"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = ["10.10.0.0/26"]
}

#################################################################################################################
# VIRTUAL MACHINES CUSTOM IMAGE (PUBLIC KEY AUTH)
#################################################################################################################

locals {
  servers = {
    blue = {
      ssh_frontend_port  = 44
      http_frontend_port = 80
    }
    green = {
      ssh_frontend_port  = 45
      http_frontend_port = 81
    }
  }
}

module "backend_machines" {
  for_each                         = local.servers
  source                           = "github.com/kolosovpetro/AzureLinuxVMTerraform.git//modules/ubuntu-vm-key-auth-custom-image-no-pip?ref=AZ400-167"
  custom_image_resource_group_name = "rg-packer-images-linux"
  custom_image_sku                 = "ubuntu2204-v1"
  ip_configuration_name            = "ipc-${each.key}-${var.prefix}"
  network_interface_name           = "nic-${each.key}-${var.prefix}"
  os_profile_admin_public_key      = file("${path.root}/id_rsa.pub")
  os_profile_admin_username        = "razumovsky_r"
  os_profile_computer_name         = "vm-${each.key}-${var.prefix}"
  resource_group_location          = azurerm_resource_group.public.location
  resource_group_name              = azurerm_resource_group.public.name
  storage_os_disk_name             = "osdisk-${each.key}-${var.prefix}"
  subnet_id                        = azurerm_subnet.internal.id
  vm_name                          = "vm-${each.key}-${var.prefix}"
  network_security_group_id        = azurerm_network_security_group.public.id
}

#################################################################################################################
# LOAD BALANCER PUBLIC IP
#################################################################################################################

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "pip-lb-${var.prefix}"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#################################################################################################################
# LOAD BALANCER
#################################################################################################################

resource "azurerm_lb" "public" {
  name                = "lb-${var.prefix}"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "fipc-lb-${var.prefix}"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

#################################################################################################################
# LOAD BALANCER BACKEND POOLS
#################################################################################################################

resource "azurerm_lb_backend_address_pool" "backend_pools" {
  for_each        = local.servers
  loadbalancer_id = azurerm_lb.public.id
  name            = "${each.key}-pool"
}

#################################################################################################################
# LOAD BALANCER BACKEND POOL ASSOCIATION
#################################################################################################################

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

#################################################################################################################
# LOAD BALANCER HEALTH PROBES
#################################################################################################################

resource "azurerm_lb_probe" "blue_http_probe" {
  loadbalancer_id = azurerm_lb.public.id
  name            = "blue-http-probe"
  port            = local.servers.blue.http_frontend_port
}

#################################################################################################################
# LOAD BALANCER RULES
#################################################################################################################

resource "azurerm_lb_rule" "http_lb_rules" {
  loadbalancer_id                = azurerm_lb.public.id
  name                           = "blue-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = local.servers.blue.http_frontend_port
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.public.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.blue_http_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pools["blue"].id]

  depends_on = [
    azurerm_lb_probe.blue_http_probe
  ]
}

#################################################################################################################
# SSH NAT RULES
#################################################################################################################

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

#################################################################################################################
# HTTP NAT RULES
#################################################################################################################

resource "azurerm_lb_nat_rule" "green_http_nat_rule" {
  resource_group_name            = azurerm_resource_group.public.name
  loadbalancer_id                = azurerm_lb.public.id
  name                           = "green-http-nat"
  protocol                       = "Tcp"
  frontend_port                  = local.servers.green.http_frontend_port
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.public.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_nat_rule_association" "green_http_nat_rule_association" {
  network_interface_id  = module.backend_machines["green"].network_interface_id
  ip_configuration_name = module.backend_machines["green"].ip_configuration_name
  nat_rule_id           = azurerm_lb_nat_rule.green_http_nat_rule.id

  depends_on = [
    module.backend_machines,
    azurerm_lb_nat_rule.green_http_nat_rule
  ]
}

