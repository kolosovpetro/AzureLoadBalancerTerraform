output "ssh_command_blue" {
  value = "ssh -p ${local.servers.blue.ssh_frontend_port} razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}"
}

output "ssh_command_green" {
  value = "ssh -p ${local.servers.green.ssh_frontend_port} razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}"
}
