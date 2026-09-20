output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}
output "key_vault_name" {
  value = azurerm_key_vault.lab.name
}
output "dc01_public_ip" {
  value = azurerm_public_ip.dc01.ip_address
}
output "dc01_private_ip" {
  value = azurerm_network_interface.dc01.private_ip_address
}
output "fs01_public_ip" {
  value = azurerm_public_ip.fs01.ip_address
}
output "client01_public_ip" {
  value = azurerm_public_ip.client01.ip_address
}
