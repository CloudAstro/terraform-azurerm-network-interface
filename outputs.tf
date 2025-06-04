output "interface" {
  value       = azurerm_network_interface.interface
  description = <<DESCRIPTION
  * `name` - (Required) The name of the Network Interface. Changing this forces a new resource to be created.
  * `resource_group_name` - (Required) The name of the Resource Group in which to create the Network Interface. Changing this forces a new resource to be created.
  * `location` - (Required) The location where the Network Interface should exist. Changing this forces a new resource to be created.
  * `auxiliary_mode` - (Optional) Specifies the auxiliary mode used to enable network high-performance feature on Network Virtual Appliances (NVAs). This feature offers competitive performance in Connections Per Second (CPS) optimization, along with improvements to handling large amounts of simultaneous connections. Possible values are `AcceleratedConnections`, `Floating`, `MaxConnections` and `None`.
  * `auxiliary_sku` - (Optional) Specifies the SKU used for the network high-performance feature on Network Virtual Appliances (NVAs). Possible values are `A8`, `A4`, `A1`, `A2` and `None`.
  * `dns_servers` - (Optional) A list of IP Addresses defining the DNS Servers which should be used for this Network Interface.
  * `edge_zone` - (Optional) Specifies the Edge Zone within the Azure Region where this Network Interface should exist. Changing this forces a new Network Interface to be created.
  * `ip_forwarding_enabled` - (Optional) Should IP Forwarding be enabled? Defaults to `false`.
  * `accelerated_networking_enabled` - (Optional) Should Accelerated Networking be enabled? Defaults to `false`.
  * `internal_dns_name_label` - (Optional) The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network.
  * `tags` - (Optional) A mapping of tags to assign to the resource.

  The `ip_configuration` block supports the following:
  * `name` - (Required) A name used for this IP Configuration.
  * `gateway_load_balancer_frontend_ip_configuration_id` - (Optional) The Frontend IP Configuration ID of a Gateway SKU Load Balancer.
  * `subnet_id` - (Optional) The ID of the Subnet where this Network Interface should be located in.
  * `private_ip_address_version` - (Optional) The IP Version to use. Possible values are `IPv4` or `IPv6`. Defaults to `IPv4`.
  * `private_ip_address_allocation` - (Required) The allocation method used for the Private IP Address. Possible values are `Dynamic` and `Static`.
  * `public_ip_address_id` - (Optional) Reference to a Public IP Address to associate with this NIC
  * `primary` - (Optional) Is this the Primary IP Configuration? Must be `true` for the first `ip_configuration` when multiple are specified. Defaults to `false`.
  * `private_ip_address` - (Optional) The Static IP Address which should be used.

  Example output:
  ```
  output "name" {
    value = module.module_name.interface.name
  }
  ```
  DESCRIPTION
}
