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
      ssh_frontend_port = 44
      http_frontend_port = 80
    }
    green = {
      ssh_frontend_port = 45
      http_frontend_port = 81
    }
  }
}

module "backend_machines" {
  for_each                         = local.servers
  source                           = "github.com/kolosovpetro/AzureLinuxVMTerraform.git//modules/ubuntu-vm-key-auth-custom-image?ref=master"
  custom_image_resource_group_name = "rg-packer-images-linux"
  custom_image_sku                 = "ubuntu2204-v1"
  ip_configuration_name            = "ipc-${each.key}-${var.prefix}"
  network_interface_name           = "nic-${each.key}-${var.prefix}"
  os_profile_admin_public_key      = file("${path.root}/id_rsa.pub")
  os_profile_admin_username        = "razumovsky_r"
  os_profile_computer_name         = "vm-${each.key}-${var.prefix}"
  public_ip_name                   = "pip-${each.key}-${var.prefix}"
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

  depends_on = [
    azurerm_public_ip.lb_public_ip
  ]
}

#################################################################################################################
# LOAD BALANCER BACKEND POOLS
#################################################################################################################

resource "azurerm_lb_backend_address_pool" "backend_pools" {
  for_each        = local.servers
  loadbalancer_id = azurerm_lb.public.id
  name            = "${each.key}-pool"
}

