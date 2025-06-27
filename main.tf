resource "azurerm_network_interface" "interface" {
  for_each = var.interfaces != null ? var.interfaces : {}

  name                           = each.value.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  auxiliary_mode                 = each.value.auxiliary_mode
  auxiliary_sku                  = each.value.auxiliary_sku
  dns_servers                    = each.value.dns_servers
  edge_zone                      = each.value.edge_zone
  ip_forwarding_enabled          = each.value.ip_forwarding_enabled
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  internal_dns_name_label        = each.value.internal_dns_name_label
  tags                           = var.tags

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration != null ? each.value.ip_configuration : []

    content {
      name                                               = ip_configuration.value.name
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id
      subnet_id                                          = ip_configuration.value.subnet_id
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      public_ip_address_id                               = ip_configuration.value.public_ip_address_id
      primary                                            = ip_configuration.value.primary
      private_ip_address                                 = ip_configuration.value.private_ip_address
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.ip_configuration != null && length(each.value.ip_configuration) > 0 && each.value.ip_configuration[0].primary == true
      error_message = "At least one ip_configuration block is required, and the first (index 0) must have primary = true."
    }
  }
}
