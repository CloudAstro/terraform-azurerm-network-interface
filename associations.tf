resource "azurerm_network_interface_security_group_association" "nsg_association" {
  for_each = var.interfaces != null ? { for key, value in var.interfaces : key => value if value.network_security_group_id != null } : null

  network_interface_id      = azurerm_network_interface.interface[each.key].id
  network_security_group_id = each.value.network_security_group_id
}

resource "azurerm_network_interface_application_security_group_association" "asg_association" {
  for_each = var.interfaces != null ? { for key, value in var.interfaces : key => value if value.application_security_group_id != null } : null

  network_interface_id          = azurerm_network_interface.interface[each.key].id
  application_security_group_id = each.value.application_security_group_id
}