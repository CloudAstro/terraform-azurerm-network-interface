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
