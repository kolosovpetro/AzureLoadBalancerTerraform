output "lb_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "ssh_command_blue" {
  value = "ssh -p ${local.servers.blue.ssh_frontend_port} razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}"
}

output "copy_command_blue" {
  value = "ssh -p ${local.servers.blue.ssh_frontend_port} razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address} \"sudo cp /tmp/blue.html /var/www/html/index.nginx-debian.html && sudo systemctl restart nginx\""
}

output "scp_command_blue" {
  value = "scp -P ${local.servers.blue.ssh_frontend_port} ./html/blue.html razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}:/tmp/blue.html"
}

output "scp_command_green" {
  value = "scp -P ${local.servers.green.ssh_frontend_port} ./html/green.html razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}:/tmp/green.html"
}

output "ssh_command_green" {
  value = "ssh -p ${local.servers.green.ssh_frontend_port} razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address}"
}

output "copy_command_green" {
  value = "ssh -p ${local.servers.green.ssh_frontend_port} razumovsky_r@${azurerm_public_ip.lb_public_ip.ip_address} \"sudo cp /tmp/green.html /var/www/html/index.nginx-debian.html && sudo systemctl restart nginx\""
}

output "nat_rule_http_url" {
  value = "http://${azurerm_public_ip.lb_public_ip.ip_address}:81"
}

output "lb_rule_blue_backend_pool" {
  value = "http://${azurerm_public_ip.lb_public_ip.ip_address}"
}
