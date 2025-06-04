variable "location" {
  type        = string
  description = <<DESCRIPTION
  * `location` - (Required) The Azure region where the virtual network (VNet) will be created. This value must be specified and cannot be null.

  Example Input:
  ```
  location = "eastus"
  ```
  DESCRIPTION
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
  * `resource_group_name` - (Required) The name of the resource group where the network interface will be created.

  Example Input:
  ```
  resource_group_name = "my-resource-group"
  ```
  DESCRIPTION
  nullable    = false
}

variable "interfaces" {
  type = map(object({
    name                           = string
    auxiliary_mode                 = optional(string)
    auxiliary_sku                  = optional(string)
    dns_servers                    = optional(list(string))
    edge_zone                      = optional(string)
    ip_forwarding_enabled          = optional(bool, false)
    accelerated_networking_enabled = optional(bool, false)
    internal_dns_name_label        = optional(string)
    network_security_group_id      = optional(string)
    application_security_group_id  = optional(string)
    ip_configuration = optional(list(object({
      name                                               = string
      gateway_load_balancer_frontend_ip_configuration_id = optional(string)
      subnet_id                                          = optional(string)
      private_ip_address_version                         = optional(string)
      private_ip_address_allocation                      = string
      public_ip_address_id                               = optional(string)
      primary                                            = optional(bool, true)
      private_ip_address                                 = optional(string)
    })))
  }))
  default     = null
  description = <<DESCRIPTION
 * `interfaces` - (Optional) A list of Network Interfaces to be created.
    * `name` - (Required) The name of the Network Interface. Changing this forces a new resource to be created.
    * `auxiliary_mode` - (Optional) Specifies the auxiliary mode used to enable network high-performance feature on Network Virtual Appliances (NVAs). This feature offers competitive performance in Connections Per Second (CPS) optimization, along with improvements to handling large amounts of simultaneous connections. Possible values are `AcceleratedConnections`, `Floating`, `MaxConnections` and `None`.
     -> **Note:** `auxiliary_mode` is in **Preview** and requires that the preview is enabled - [more information can be found in the Azure documentation](https://learn.microsoft.com/azure/networking/nva-accelerated-connections#prerequisites).
    * `auxiliary_sku` - (Optional) Specifies the SKU used for the network high-performance feature on Network Virtual Appliances (NVAs). Possible values are `A8`, `A4`, `A1`, `A2` and `None`.
     -> **Note:** `auxiliary_sku` is in **Preview** and requires that the preview is enabled - [more information can be found in the Azure documentation](https://learn.microsoft.com/azure/networking/nva-accelerated-connections#prerequisites).
    * `dns_servers` - (Optional) A list of IP Addresses defining the DNS Servers which should be used for this Network Interface.
     -> **Note:** Configuring DNS Servers on the Network Interface will override the DNS Servers defined on the Virtual Network.
    * `edge_zone` - (Optional) Specifies the Edge Zone within the Azure Region where this Network Interface should exist. Changing this forces a new Network Interface to be created.
    * `ip_forwarding_enabled` - (Optional) Should IP Forwarding be enabled? Defaults to `false`.
    * `accelerated_networking_enabled` - (Optional) Should Accelerated Networking be enabled? Defaults to `false`.
     -> **Note:** Only certain Virtual Machine sizes are supported for Accelerated Networking - [more information can be found in this document](https://docs.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-cli).
     -> **Note:** To use Accelerated Networking in an Availability Set, the Availability Set must be deployed onto an Accelerated Networking enabled cluster.
    * `internal_dns_name_label` - (Optional) The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network.
    * `ip_configuration` - The `ip_configuration` block supports the following:
      * `name` - (Required) A name used for this IP Configuration.
      * `gateway_load_balancer_frontend_ip_configuration_id` - (Optional) The Frontend IP Configuration ID of a Gateway SKU Load Balancer.
      * `subnet_id` - (Optional) The ID of the Subnet where this Network Interface should be located in.
       -> **Note:** This is required when `private_ip_address_version` is set to `IPv4`.
      * `private_ip_address_version` - (Optional) The IP Version to use. Possible values are `IPv4` or `IPv6`. Defaults to `IPv4`.
      * `private_ip_address_allocation` - (Required) The allocation method used for the Private IP Address. Possible values are `Dynamic` and `Static`.
       ~> **Note:** `Dynamic` means "An IP is automatically assigned during creation of this Network Interface"; `Static` means "User supplied IP address will be used"
      * `public_ip_address_id` - (Optional) Reference to a Public IP Address to associate with this NIC
      * `primary` - (Optional) Is this the Primary IP Configuration? Must be `true` for the first `ip_configuration` when multiple are specified. Defaults to `false`.      When `private_ip_address_allocation` is set to `Static` the following fields can be configured:
      * `private_ip_address` - (Optional) The Static IP Address which should be used.

 Example Input:
 ```
  interfaces = {
   example-nic = {
    name                           = "example-nic"
    auxiliary_mode                 = "AcceleratedConnections"
    auxiliary_sku                  = "A2"
    dns_servers                    = ["10.0.0.4", "10.0.0.5"]
    edge_zone                      = "centraluseuap-1"
    ip_forwarding_enabled          = true
    accelerated_networking_enabled = true
    internal_dns_name_label        = "example-nic-label"

    ip_configuration = [
      {
        name                          = "internal-ipconfig"
        subnet_id                     = "/subscriptions/xxxx/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/vnet1/subnets/subnet1"
        private_ip_address_version    = "IPv4"
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.1.5"
        public_ip_address_id          = "/subscriptions/xxxx/resourceGroups/my-rg/providers/Microsoft.Network/publicIPAddresses/public-ip-1"
        gateway_load_balancer_frontend_ip_configuration_id = "/subscriptions/xxxx/resourceGroups/my-rg/providers/Microsoft.Network/loadBalancers/gateway-lb/frontendIPConfigurations/frontend1"
        primary                       = true
      }
    ]
   }
  }
 ```
 DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
  * `tags` - (Optional) A map of tags to associate with the network and subnets.

  Example Input:
  ```
  tags = {
    "environment" = "production"
    "department"  = "IT"
  }
  ```
  DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string, "30")
    update = optional(string, "30")
    read   = optional(string, "5")
    delete = optional(string, "30")
  })
  default     = null
  description = <<DESCRIPTION
  The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
   * `create` - (Defaults to 30 minutes) Used when creating the Network Interface.
   * `update` - (Defaults to 30 minutes) Used when updating the Network Interface.
   * `read` - (Defaults to 5 minutes) Used when retrieving the Network Interface.
   * `delete` - (Defaults to 30 minutes) Used when deleting the Network Interface.

 Example Input:
 ```
  timeouts = {
    create = "30"
    update = "30"
    read   = "5"
    delete = "30"
  }
 ```
 DESCRIPTION
}
