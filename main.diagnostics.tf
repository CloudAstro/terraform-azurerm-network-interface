#Create diagnostic setting for Azure Network Interface
resource "azurerm_monitor_diagnostic_setting" "this_nic_diags" {
  for_each = { for k, v in local.nics_diagnostic_settings : k => v if v.enable_diagnostics }

  name                           = each.value.diagnostic_settings.name
  target_resource_id             = azurerm_network_interface.interface[each.value.interface_name].id
  eventhub_name                  = each.value.diagnostic_settings.eventhub_name
  eventhub_authorization_rule_id = each.value.diagnostic_settings.eventhub_authorization_rule_id
  log_analytics_workspace_id     = each.value.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = each.value.diagnostic_settings.storage_account_id
  log_analytics_destination_type = each.value.diagnostic_settings.log_analytics_destination_type
  partner_solution_id            = each.value.diagnostic_settings.partner_solution_id

  dynamic "metric" {
    for_each = each.value.diagnostic_settings.metric != null ? [each.value.diagnostic_settings.metric] : []

    content {
      category = metric.value.category
      enabled  = metric.value.enabled
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }
}