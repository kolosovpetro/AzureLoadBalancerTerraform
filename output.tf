output "ssh_command_blue" {
  value = "ssh razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}:44"
}

output "ssh_command_green" {
  value = "ssh razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}:45"
}
