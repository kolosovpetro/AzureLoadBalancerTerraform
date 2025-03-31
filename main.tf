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
      indexer                        = "blue"
      index_value                    = 0
      ssh_frontend_port              = 22
      http_frontend_port             = 80
      public_ip_name                 = "pip-blue-${var.prefix}"
      frontend_ip_configuration_name = "fipc-blue-${var.prefix}"
      backend_pool_name              = "backend-pool-blue-${var.prefix}"
      lb_probe_name                  = "lb-probe-blue-${var.prefix}"
      lb_rule_name                   = "lb-rule-blue-${var.prefix}"
      ssh_nat_rule_name              = "nat-rule-blue-${var.prefix}"
    }
    green = {
      indexer                        = "green"
      index_value                    = 0
      ssh_frontend_port              = 22
      http_frontend_port             = 80
      public_ip_name                 = "pip-green-${var.prefix}"
      frontend_ip_configuration_name = "fipc-green-${var.prefix}"
      backend_pool_name              = "backend-pool-green-${var.prefix}"
      lb_probe_name                  = "lb-probe-green-${var.prefix}"
      lb_rule_name                   = "lb-rule-green-${var.prefix}"
      ssh_nat_rule_name              = "nat-rule-green-${var.prefix}"
    }
  }
}

module "backend_machines" {
  for_each                         = local.servers
  source                           = "github.com/kolosovpetro/AzureLinuxVMTerraform.git//modules/ubuntu-vm-key-auth-custom-image-no-pip?ref=master"
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
  for_each            = local.servers
  name                = each.value.public_ip_name
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
    name                 = local.servers.blue.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.lb_public_ip["blue"].id
  }

  frontend_ip_configuration {
    name                 = local.servers.green.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.lb_public_ip["green"].id
  }
}

#################################################################################################################
# LOAD BALANCER BACKEND POOLS
#################################################################################################################

resource "azurerm_lb_backend_address_pool" "backend_pools" {
  for_each        = local.servers
  loadbalancer_id = azurerm_lb.public.id
  name            = each.value.backend_pool_name
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

resource "azurerm_lb_probe" "http_lb_probes" {
  for_each        = local.servers
  loadbalancer_id = azurerm_lb.public.id
  name            = each.value.lb_probe_name
  port            = each.value.http_frontend_port
}

#################################################################################################################
# LOAD BALANCER RULES
#################################################################################################################

resource "azurerm_lb_rule" "http_lb_rules" {
  for_each                       = local.servers
  loadbalancer_id                = azurerm_lb.public.id
  name                           = each.value.lb_rule_name
  protocol                       = "Tcp"
  frontend_port                  = each.value.http_frontend_port
  backend_port                   = 80
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  probe_id                       = azurerm_lb_probe.http_lb_probes[each.key].id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pools[each.key].id]

  depends_on = [
    azurerm_lb_probe.http_lb_probes
  ]
}

#################################################################################################################
# SSH NAT RULES
#################################################################################################################

resource "azurerm_lb_nat_rule" "ssh_nat_rules" {
  for_each                       = local.servers
  resource_group_name            = azurerm_resource_group.public.name
  loadbalancer_id                = azurerm_lb.public.id
  name                           = each.value.ssh_nat_rule_name
  protocol                       = "Tcp"
  frontend_port                  = each.value.ssh_frontend_port
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.public.frontend_ip_configuration[each.value.index_value].name

  depends_on = [
    azurerm_lb.public
  ]
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

