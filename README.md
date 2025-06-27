<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
# Azure Network Interface Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/CloudAstro/network-interface/azurerm/)

This module manages the creation and configuration of Network Interfaces in Microsoft Azure. It allows you to define various settings such as IP configurations, DNS servers, and network security groups.

## Features

- **Network Interface Creation**: Provision and configure Azure Network Interfaces with various settings.
- **IP Configuration**: Manage both private and public IP addresses with flexible allocation methods.
- **DNS Management**: Customize DNS servers for the Network Interface, overriding the default settings of the Virtual Network if needed.
- **Network Security**: Attach Network Security Groups (NSGs) and Application Security Groups (ASGs) to manage traffic flow.
- **Accelerated Networking**: Enable or disable accelerated networking to enhance performance for supported VM sizes.

## Example Usage

This example demonstrates how to deploy a Network Interface with custom IP configurations and optionally associate it with a Network Security Group, Public IP, or Application Security Group.

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-nic-example"
  location = "germanywestcentral"
}

module "vnet" {
  source              = "CloudAstro/virtual-network/azurerm"
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "snet" {
  source               = "CloudAstro/subnet/azurerm"
  name                 = "snet-example"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "network_interface" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  interfaces = {
    first-nic = {
      name                           = "first-nic"
      dns_servers                    = ["168.63.129.16", "8.8.8.8"]
      accelerated_networking_enabled = false
      ip_forwarding_enabled          = true
      internal_dns_name_label        = "vm-internal"

      ip_configuration = [
        {
          name                          = "internal"
          subnet_id                     = module.snet.subnet.id
          private_ip_address_version    = "IPv4"
          private_ip_address_allocation = "Static"
          primary                       = true
          private_ip_address            = "10.0.1.6"
        }
      ]
    }

    second-nic = {
      name                           = "second-nic"
      dns_servers                    = ["168.63.129.16", "8.8.8.8"]
      accelerated_networking_enabled = true
      ip_forwarding_enabled          = false
      internal_dns_name_label        = "vm-internal-2"

      ip_configuration = [
        {
          name                          = "internal"
          subnet_id                     = module.snet.subnet.id
          private_ip_address_version    = "IPv4"
          private_ip_address_allocation = "Dynamic"
          primary                       = true
        },
        {
          name                          = "external"
          subnet_id                     = module.snet.subnet.id
          private_ip_address_version    = "IPv4"
          private_ip_address_allocation = "Dynamic"
          primary                       = false
        }
      ]
    }
  }

  tags = {
    environment = "production"
    department  = "IT"
  }
}
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.this_nic_diags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_interface.interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_application_security_group_association.asg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | * `location` - (Required) The Azure region where the virtual network (VNet) will be created. This value must be specified and cannot be null.<br/><br/>  Example Input:<pre>location = "eastus"</pre> | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | * `resource_group_name` - (Required) The name of the resource group where the network interface will be created.<br/><br/>  Example Input:<pre>resource_group_name = "my-resource-group"</pre> | `string` | n/a | yes |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | * `monitor_diagnostic_setting` - Manages a Diagnostic Setting for an existing Resource.<br/>  * `name` - (Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created.<br/>  -> **NOTE:** If the name is set to 'service' it will not be possible to fully delete the diagnostic setting. This is due to legacy API support.<br/>  * `target_resource_id` - (Optional) The ID of an existing Resource on which to configure Diagnostic Settings. Changing this forces a new resource to be created.<br/>  * `eventhub_name` - (Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent.<br/>  -> **NOTE:** If this isn't specified then the default Event Hub will be used.<br/>  * `eventhub_authorization_rule_id` - (Optional) Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data. <br/>  -> **NOTE:** This can be sourced from [the `azurerm_eventhub_namespace_authorization_rule` resource](eventhub\_namespace\_authorization\_rule.html) and is different from [a `azurerm_eventhub_authorization_rule` resource](eventhub\_authorization\_rule.html).<br/>  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `log_analytics_workspace_id` - (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.<br/>  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `storage_account_id` - (Optional) The ID of the Storage Account where logs should be sent. <br/>  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `log_analytics_destination_type` - (Optional) Possible values are `AzureDiagnostics` and `Dedicated`. When set to `Dedicated`, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy `AzureDiagnostics` table.<br/>  -> **NOTE:** This setting will only have an effect if a `log_analytics_workspace_id` is provided. For some target resource type (e.g., Key Vault), this field is unconfigurable. Please see [resource types](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resource-types) for services that use each method. Please [see the documentation](https://docs.microsoft.com/azure/azure-monitor/platform/diagnostic-logs-stream-log-store#azure-diagnostics-vs-resource-specific) for details on the differences between destination types.<br/>  * `partner_solution_id` - (Optional) The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, [click to learn more about partner integration](https://learn.microsoft.com/en-us/azure/partner-solutions/overview).<br/>  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `metric` - (Optional) One or more `metric` blocks as defined below.<br/>    * `category` - (Required) The name of a Diagnostic Metric Category for this Resource.<br/>    * -> **NOTE:** The Metric Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor\_diagnostic\_categories.html) to identify which categories are available for a given Resource.<br/>    * `enabled` - (Optional) Is this Diagnostic Metric enabled? Defaults to `true`.<br/>  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:<br/>   * `create` - (Defaults to 30 minutes) Used when creating the Diagnostics Setting.<br/>   * `update` - (Defaults to 30 minutes) Used when updating the Diagnostics Setting.<br/>   * `read` - (Defaults to 5 minutes) Used when retrieving the Diagnostics Setting.<br/>   * `delete` - (Defaults to 60 minutes) Used when deleting the Diagnostics Setting.<br/> <br/> Example Input:<pre>diagnostic_settings = {<br/>  nic = {<br/>    name                           = "nic-diagnostics"<br/>    target_resource_id             = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/networkInterfaces/example-nic"<br/>    log_analytics_workspace_id     = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.OperationalInsights/workspaces/myLogAnalyticsWorkspace"<br/>    storage_account_id             = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/myStorageAccount"<br/>    eventhub_authorization_rule_id = null<br/>    eventhub_name                  = null<br/>    partner_solution_id            = null<br/>    log_analytics_destination_type = "Dedicated"<br/><br/>    metric = [<br/>      {<br/>        category = "AllMetrics"<br/>        enabled  = true<br/>      }<br/>    ]<br/><br/>    timeouts = {<br/>      create = "30"<br/>      update = "30"<br/>      read   = "5"<br/>      delete = "60"<br/>    }<br/>  }<br/> }</pre> | <pre>map(object({<br/>    name                           = string<br/>    target_resource_id             = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    partner_solution_id            = optional(string)<br/>    metric = optional(set(object({<br/>      category = optional(string, "AllMetrics")<br/>      enabled  = optional(bool, true)<br/>    })))<br/>    timeouts = optional(object({<br/>      create = optional(string, "30")<br/>      update = optional(string, "30")<br/>      read   = optional(string, "5")<br/>      delete = optional(string, "60")<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | * `interfaces` - (Optional) A list of Network Interfaces to be created.<br/>    * `name` - (Required) The name of the Network Interface. Changing this forces a new resource to be created.<br/>    * `auxiliary_mode` - (Optional) Specifies the auxiliary mode used to enable network high-performance feature on Network Virtual Appliances (NVAs). This feature offers competitive performance in Connections Per Second (CPS) optimization, along with improvements to handling large amounts of simultaneous connections. Possible values are `AcceleratedConnections`, `Floating`, `MaxConnections` and `None`.<br/>     -> **Note:** `auxiliary_mode` is in **Preview** and requires that the preview is enabled - [more information can be found in the Azure documentation](https://learn.microsoft.com/azure/networking/nva-accelerated-connections#prerequisites).<br/>    * `auxiliary_sku` - (Optional) Specifies the SKU used for the network high-performance feature on Network Virtual Appliances (NVAs). Possible values are `A8`, `A4`, `A1`, `A2` and `None`.<br/>     -> **Note:** `auxiliary_sku` is in **Preview** and requires that the preview is enabled - [more information can be found in the Azure documentation](https://learn.microsoft.com/azure/networking/nva-accelerated-connections#prerequisites).<br/>    * `dns_servers` - (Optional) A list of IP Addresses defining the DNS Servers which should be used for this Network Interface.<br/>     -> **Note:** Configuring DNS Servers on the Network Interface will override the DNS Servers defined on the Virtual Network.<br/>    * `edge_zone` - (Optional) Specifies the Edge Zone within the Azure Region where this Network Interface should exist. Changing this forces a new Network Interface to be created.<br/>    * `ip_forwarding_enabled` - (Optional) Should IP Forwarding be enabled? Defaults to `false`.<br/>    * `accelerated_networking_enabled` - (Optional) Should Accelerated Networking be enabled? Defaults to `false`.<br/>     -> **Note:** Only certain Virtual Machine sizes are supported for Accelerated Networking - [more information can be found in this document](https://docs.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-cli).<br/>     -> **Note:** To use Accelerated Networking in an Availability Set, the Availability Set must be deployed onto an Accelerated Networking enabled cluster.<br/>    * `internal_dns_name_label` - (Optional) The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network.<br/>    * `ip_configuration` - The `ip_configuration` block supports the following:<br/>      * `name` - (Required) A name used for this IP Configuration.<br/>      * `gateway_load_balancer_frontend_ip_configuration_id` - (Optional) The Frontend IP Configuration ID of a Gateway SKU Load Balancer.<br/>      * `subnet_id` - (Optional) The ID of the Subnet where this Network Interface should be located in.<br/>       -> **Note:** This is required when `private_ip_address_version` is set to `IPv4`.<br/>      * `private_ip_address_version` - (Optional) The IP Version to use. Possible values are `IPv4` or `IPv6`. Defaults to `IPv4`.<br/>      * `private_ip_address_allocation` - (Required) The allocation method used for the Private IP Address. Possible values are `Dynamic` and `Static`.<br/>       ~> **Note:** `Dynamic` means "An IP is automatically assigned during creation of this Network Interface"; `Static` means "User supplied IP address will be used"<br/>      * `public_ip_address_id` - (Optional) Reference to a Public IP Address to associate with this NIC<br/>      * `primary` - (Optional) Is this the Primary IP Configuration? Must be `true` for the first `ip_configuration` when multiple are specified. Defaults to `false`.      When `private_ip_address_allocation` is set to `Static` the following fields can be configured:<br/>      * `private_ip_address` - (Optional) The Static IP Address which should be used.<br/><br/> Example Input:<pre>interfaces = {<br/>   example-nic = {<br/>    name                           = "example-nic"<br/>    auxiliary_mode                 = "AcceleratedConnections"<br/>    auxiliary_sku                  = "A2"<br/>    dns_servers                    = ["10.0.0.4", "10.0.0.5"]<br/>    edge_zone                      = "centraluseuap-1"<br/>    ip_forwarding_enabled          = true<br/>    accelerated_networking_enabled = true<br/>    internal_dns_name_label        = "example-nic-label"<br/><br/>    ip_configuration = [<br/>      {<br/>        name                          = "internal-ipconfig"<br/>        subnet_id                     = "/subscriptions/xxxx/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1"<br/>        private_ip_address_version    = "IPv4"<br/>        private_ip_address_allocation = "Static"<br/>        private_ip_address            = "10.0.1.5"<br/>        public_ip_address_id          = "/subscriptions/xxxx/resourceGroups/my-rg/providers/Microsoft.Network/publicIPAddresses/public-ip-1"<br/>        gateway_load_balancer_frontend_ip_configuration_id = "/subscriptions/xxxx/resourceGroups/my-rg/providers/Microsoft.Network/loadBalancers/gateway-lb/frontendIPConfigurations/frontend1"<br/>        primary                       = true<br/>      }<br/>    ]<br/>   }<br/>  }</pre> | <pre>map(object({<br/>    name                           = string<br/>    auxiliary_mode                 = optional(string)<br/>    auxiliary_sku                  = optional(string)<br/>    dns_servers                    = optional(list(string))<br/>    edge_zone                      = optional(string)<br/>    ip_forwarding_enabled          = optional(bool, false)<br/>    accelerated_networking_enabled = optional(bool, false)<br/>    internal_dns_name_label        = optional(string)<br/>    network_security_group_id      = optional(string)<br/>    application_security_group_id  = optional(string)<br/>    ip_configuration = optional(list(object({<br/>      name                                               = string<br/>      gateway_load_balancer_frontend_ip_configuration_id = optional(string)<br/>      subnet_id                                          = optional(string)<br/>      private_ip_address_version                         = optional(string)<br/>      private_ip_address_allocation                      = string<br/>      public_ip_address_id                               = optional(string)<br/>      primary                                            = optional(bool, true)<br/>      private_ip_address                                 = optional(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | * `tags` - (Optional) A map of tags to associate with the network and subnets.<br/><br/>  Example Input:<pre>tags = {<br/>    "environment" = "production"<br/>    "department"  = "IT"<br/>  }</pre> | `map(string)` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:<br/>   * `create` - (Defaults to 30 minutes) Used when creating the Network Interface.<br/>   * `update` - (Defaults to 30 minutes) Used when updating the Network Interface.<br/>   * `read` - (Defaults to 5 minutes) Used when retrieving the Network Interface.<br/>   * `delete` - (Defaults to 30 minutes) Used when deleting the Network Interface.<br/><br/> Example Input:<pre>timeouts = {<br/>    create = "30"<br/>    update = "30"<br/>    read   = "5"<br/>    delete = "30"<br/>  }</pre> | <pre>object({<br/>    create = optional(string, "30")<br/>    update = optional(string, "30")<br/>    read   = optional(string, "5")<br/>    delete = optional(string, "30")<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interface"></a> [interface](#output\_interface) | * `name` - (Required) The name of the Network Interface. Changing this forces a new resource to be created.<br/>  * `resource_group_name` - (Required) The name of the Resource Group in which to create the Network Interface. Changing this forces a new resource to be created.<br/>  * `location` - (Required) The location where the Network Interface should exist. Changing this forces a new resource to be created.<br/>  * `auxiliary_mode` - (Optional) Specifies the auxiliary mode used to enable network high-performance feature on Network Virtual Appliances (NVAs). This feature offers competitive performance in Connections Per Second (CPS) optimization, along with improvements to handling large amounts of simultaneous connections. Possible values are `AcceleratedConnections`, `Floating`, `MaxConnections` and `None`.<br/>  * `auxiliary_sku` - (Optional) Specifies the SKU used for the network high-performance feature on Network Virtual Appliances (NVAs). Possible values are `A8`, `A4`, `A1`, `A2` and `None`.<br/>  * `dns_servers` - (Optional) A list of IP Addresses defining the DNS Servers which should be used for this Network Interface.<br/>  * `edge_zone` - (Optional) Specifies the Edge Zone within the Azure Region where this Network Interface should exist. Changing this forces a new Network Interface to be created.<br/>  * `ip_forwarding_enabled` - (Optional) Should IP Forwarding be enabled? Defaults to `false`.<br/>  * `accelerated_networking_enabled` - (Optional) Should Accelerated Networking be enabled? Defaults to `false`.<br/>  * `internal_dns_name_label` - (Optional) The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network.<br/>  * `tags` - (Optional) A mapping of tags to assign to the resource.<br/><br/>  The `ip_configuration` block supports the following:<br/>  * `name` - (Required) A name used for this IP Configuration.<br/>  * `gateway_load_balancer_frontend_ip_configuration_id` - (Optional) The Frontend IP Configuration ID of a Gateway SKU Load Balancer.<br/>  * `subnet_id` - (Optional) The ID of the Subnet where this Network Interface should be located in.<br/>  * `private_ip_address_version` - (Optional) The IP Version to use. Possible values are `IPv4` or `IPv6`. Defaults to `IPv4`.<br/>  * `private_ip_address_allocation` - (Required) The allocation method used for the Private IP Address. Possible values are `Dynamic` and `Static`.<br/>  * `public_ip_address_id` - (Optional) Reference to a Public IP Address to associate with this NIC<br/>  * `primary` - (Optional) Is this the Primary IP Configuration? Must be `true` for the first `ip_configuration` when multiple are specified. Defaults to `false`.<br/>  * `private_ip_address` - (Optional) The Static IP Address which should be used.<br/><br/>  Example output:<pre>output "name" {<br/>    value = module.module_name.interface.name<br/>  }</pre> |

## Modules

No modules.

## 🌐 Additional Information

For more details on Azure Network Interfaces and their configurations, refer to the [Azure Network Interface documentation](https://learn.microsoft.com/en-us/azure/virtual-network/network-interface-overview). This module is used to create and manage network interfaces for Azure VMs and other network resources.

## 📚 Resources

- [AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)
- [Azure Network Interface Overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-interface-overview)

## ⚠️ Notes  

- Ensure that the network interface is correctly associated with the appropriate virtual network and subnet.
- Configure network security groups (NSGs) and IP configurations to meet your network security and connectivity requirements.
- Validate your Terraform configuration before deployment to confirm that the network interface settings are applied as intended.

## 🧾 License  

This module is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->