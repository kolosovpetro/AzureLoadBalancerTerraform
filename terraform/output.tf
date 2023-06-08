output "vm1_ip" {
  value = module.ubuntu-vm-public-key-auth-one.vm_public_ip_address
}

output "vm2_ip" {
  value = module.ubuntu-vm-public-key-auth-two.vm_public_ip_address
}

output "vm3_ip" {
  value = module.ubuntu-vm-public-key-auth-three.vm_public_ip_address
}