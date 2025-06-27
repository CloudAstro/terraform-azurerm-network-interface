variable "diagnostic_settings" {
  type = map(object({
    name                           = string
    target_resource_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    log_analytics_destination_type = optional(string)
    partner_solution_id            = optional(string)
    metric = optional(set(object({
      category = optional(string, "AllMetrics")
      enabled  = optional(bool, true)
    })))
    timeouts = optional(object({
      create = optional(string, "30")
      update = optional(string, "30")
      read   = optional(string, "5")
      delete = optional(string, "60")
    }))
  }))
  default     = null
  description = <<DESCRIPTION
 * `monitor_diagnostic_setting` - Manages a Diagnostic Setting for an existing Resource.
  * `name` - (Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created.
  -> **NOTE:** If the name is set to 'service' it will not be possible to fully delete the diagnostic setting. This is due to legacy API support.
  * `target_resource_id` - (Optional) The ID of an existing Resource on which to configure Diagnostic Settings. Changing this forces a new resource to be created.
  * `eventhub_name` - (Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent.
  -> **NOTE:** If this isn't specified then the default Event Hub will be used.
  * `eventhub_authorization_rule_id` - (Optional) Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data. 
  -> **NOTE:** This can be sourced from [the `azurerm_eventhub_namespace_authorization_rule` resource](eventhub_namespace_authorization_rule.html) and is different from [a `azurerm_eventhub_authorization_rule` resource](eventhub_authorization_rule.html).
  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `log_analytics_workspace_id` - (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.
  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `storage_account_id` - (Optional) The ID of the Storage Account where logs should be sent. 
  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `log_analytics_destination_type` - (Optional) Possible values are `AzureDiagnostics` and `Dedicated`. When set to `Dedicated`, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy `AzureDiagnostics` table.
  -> **NOTE:** This setting will only have an effect if a `log_analytics_workspace_id` is provided. For some target resource type (e.g., Key Vault), this field is unconfigurable. Please see [resource types](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resource-types) for services that use each method. Please [see the documentation](https://docs.microsoft.com/azure/azure-monitor/platform/diagnostic-logs-stream-log-store#azure-diagnostics-vs-resource-specific) for details on the differences between destination types.
  * `partner_solution_id` - (Optional) The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, [click to learn more about partner integration](https://learn.microsoft.com/en-us/azure/partner-solutions/overview).
  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `metric` - (Optional) One or more `metric` blocks as defined below.
    * `category` - (Required) The name of a Diagnostic Metric Category for this Resource.
    * -> **NOTE:** The Metric Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor_diagnostic_categories.html) to identify which categories are available for a given Resource.
    * `enabled` - (Optional) Is this Diagnostic Metric enabled? Defaults to `true`.
  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
   * `create` - (Defaults to 30 minutes) Used when creating the Diagnostics Setting.
   * `update` - (Defaults to 30 minutes) Used when updating the Diagnostics Setting.
   * `read` - (Defaults to 5 minutes) Used when retrieving the Diagnostics Setting.
   * `delete` - (Defaults to 60 minutes) Used when deleting the Diagnostics Setting.
 
 Example Input:
 ```
 diagnostic_settings = {
  nic = {
    name                           = "nic-diagnostics"
    target_resource_id             = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/networkInterfaces/example-nic"
    log_analytics_workspace_id     = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.OperationalInsights/workspaces/myLogAnalyticsWorkspace"
    storage_account_id             = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/myStorageAccount"
    eventhub_authorization_rule_id = null
    eventhub_name                  = null
    partner_solution_id            = null
    log_analytics_destination_type = "Dedicated"

    metric = [
      {
        category = "AllMetrics"
        enabled  = true
      }
    ]

    timeouts = {
      create = "30"
      update = "30"
      read   = "5"
      delete = "60"
    }
  }
 }
 ```
 DESCRIPTION
  validation {
    condition = alltrue([
    for _, v in var.diagnostic_settings != null ? var.diagnostic_settings : {} : v.log_analytics_workspace_id != null || v.storage_account_id != null || v.eventhub_authorization_rule_id != null || v.partner_solution_id != null])
    error_message = "Each diagnostic setting must have at least one of the following set: log_analytics_workspace_id, storage_account_id, partner_solution_id, or eventhub_authorization_rule_id."
  }
}