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
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  interfaces = {
    nic-example = {
      name = "nic-example"
      ip_configuration = [
        {
          name                          = "ip-config-example"
          private_ip_address_allocation = "Dynamic"
          subnet_id                     = module.snet.subnet.id
        }
      ]
    }
  }
}
