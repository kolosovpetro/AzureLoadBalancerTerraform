data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "public" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}-${var.prefix}"
}

module "network" {
  source                  = "./modules/network"
  nsg_name                = var.nsg_name
  resource_group_location = azurerm_resource_group.public.location
  resource_group_name     = azurerm_resource_group.public.name
  subnet_name             = "${var.vm_name}${var.prefix}"
  vnet_name               = "${var.vnet_name}-${var.prefix}"
}

module "ubuntu-vm-public-key-auth-one" {
  source                            = "./modules/ubuntu-vm-public-key-auth"
  ip_configuration_name             = "${var.ip_configuration_name}-${var.prefix}-1"
  network_interface_name            = "${var.network_interface_name}-${var.prefix}-1"
  os_profile_admin_public_key_path  = var.os_profile_admin_public_key_path
  os_profile_admin_username         = var.os_profile_admin_username
  os_profile_computer_name          = "${var.os_profile_computer_name}${var.prefix}1"
  resource_group_location           = azurerm_resource_group.public.location
  resource_group_name               = azurerm_resource_group.public.name
  storage_image_reference_offer     = var.storage_image_reference_offer
  storage_image_reference_publisher = var.storage_image_reference_publisher
  storage_image_reference_sku       = var.storage_image_reference_sku
  storage_image_reference_version   = var.storage_image_reference_version
  storage_os_disk_caching           = var.storage_os_disk_caching
  storage_os_disk_create_option     = var.storage_os_disk_create_option
  storage_os_disk_managed_disk_type = var.storage_os_disk_managed_disk_type
  storage_os_disk_name              = "${var.storage_os_disk_name}-${var.prefix}-1"
  subnet_name                       = module.network.subnet_name
  vm_name                           = "${var.vm_name}${var.prefix}1"
  vm_size                           = var.vm_size
  vnet_name                         = module.network.vnet_name
  public_ip_name                    = "${var.public_ip_name}-${var.prefix}-1"
  subnet_id                         = module.network.subnet_id
  nsg_name                          = "${var.nsg_name}-${var.prefix}-1"

  depends_on = [
    azurerm_resource_group.public,
    module.network.subnet_name,
    module.network.vnet_name,
    module.network.subnet_id
  ]
}

module "ubuntu-vm-public-key-auth-two" {
  source                            = "./modules/ubuntu-vm-public-key-auth"
  ip_configuration_name             = "${var.ip_configuration_name}-${var.prefix}-2"
  network_interface_name            = "${var.network_interface_name}-${var.prefix}-2"
  os_profile_admin_public_key_path  = var.os_profile_admin_public_key_path
  os_profile_admin_username         = var.os_profile_admin_username
  os_profile_computer_name          = "${var.os_profile_computer_name}${var.prefix}2"
  resource_group_location           = azurerm_resource_group.public.location
  resource_group_name               = azurerm_resource_group.public.name
  storage_image_reference_offer     = var.storage_image_reference_offer
  storage_image_reference_publisher = var.storage_image_reference_publisher
  storage_image_reference_sku       = var.storage_image_reference_sku
  storage_image_reference_version   = var.storage_image_reference_version
  storage_os_disk_caching           = var.storage_os_disk_caching
  storage_os_disk_create_option     = var.storage_os_disk_create_option
  storage_os_disk_managed_disk_type = var.storage_os_disk_managed_disk_type
  storage_os_disk_name              = "${var.storage_os_disk_name}-${var.prefix}-2"
  subnet_name                       = module.network.subnet_name
  vm_name                           = "${var.vm_name}${var.prefix}2"
  vm_size                           = var.vm_size
  vnet_name                         = module.network.vnet_name
  public_ip_name                    = "${var.public_ip_name}-${var.prefix}-2"
  subnet_id                         = module.network.subnet_id
  nsg_name                          = "${var.nsg_name}-${var.prefix}-2"

  depends_on = [
    azurerm_resource_group.public,
    module.network.subnet_name,
    module.network.vnet_name,
    module.network.subnet_id
  ]
}

module "ubuntu-vm-public-key-auth-three" {
  source                            = "./modules/ubuntu-vm-public-key-auth"
  ip_configuration_name             = "${var.ip_configuration_name}-${var.prefix}-3"
  network_interface_name            = "${var.network_interface_name}-${var.prefix}-3"
  os_profile_admin_public_key_path  = var.os_profile_admin_public_key_path
  os_profile_admin_username         = var.os_profile_admin_username
  os_profile_computer_name          = "${var.os_profile_computer_name}${var.prefix}3"
  resource_group_location           = azurerm_resource_group.public.location
  resource_group_name               = azurerm_resource_group.public.name
  storage_image_reference_offer     = var.storage_image_reference_offer
  storage_image_reference_publisher = var.storage_image_reference_publisher
  storage_image_reference_sku       = var.storage_image_reference_sku
  storage_image_reference_version   = var.storage_image_reference_version
  storage_os_disk_caching           = var.storage_os_disk_caching
  storage_os_disk_create_option     = var.storage_os_disk_create_option
  storage_os_disk_managed_disk_type = var.storage_os_disk_managed_disk_type
  storage_os_disk_name              = "${var.storage_os_disk_name}-${var.prefix}-3"
  subnet_name                       = module.network.subnet_name
  vm_name                           = "${var.vm_name}${var.prefix}3"
  vm_size                           = var.vm_size
  vnet_name                         = module.network.vnet_name
  public_ip_name                    = "${var.public_ip_name}-${var.prefix}-3"
  subnet_id                         = module.network.subnet_id
  nsg_name                          = "${var.nsg_name}-${var.prefix}-3"

  depends_on = [
    azurerm_resource_group.public,
    module.network.subnet_name,
    module.network.vnet_name,
    module.network.subnet_id
  ]
}