# Resource group
resource "azurerm_resource_group" "dns_rg" {
  name     = "rg-dns-${var.resource_group_location}"
  location = var.resource_group_location
}

#VNet
resource "azurerm_virtual_network" "hub_extension_vnet" {
  name                = "${var.resource_group_location}-vnet-hub-extension"
  location            = azurerm_resource_group.dns_rg.location
  resource_group_name = azurerm_resource_group.dns_rg.name
  address_space       = [var.address_space]
}

#Subnet
resource "azurerm_subnet" "inbound_endpoint_subnet" {
  name                 = "${var.resource_group_location}-subnet-inbound-endpoint"
  resource_group_name  = azurerm_resource_group.dns_rg.name
  virtual_network_name = azurerm_virtual_network.hub_extension_vnet.name
  address_prefixes     = [var.address_prefix]
}

resource "azurerm_private_dns_resolver" "private_dns_resolver" {
  name                = "${var.resource_group_location}-private_dns_resolver"
  resource_group_name = azurerm_resource_group.dns_rg.name
  location            = azurerm_resource_group.dns_rg.location
  virtual_network_id  = azurerm_virtual_network.hub_extension_vnet.id
}

#Private DNS Zones
resource "azurerm_private_dns_zone" "connectivity" {
  for_each = var.private_dns_zone_names

  # Mandatory resource attributes
  name                = each.value
  resource_group_name = azurerm_resource_group.dns_rg.name

  # Dynamic configuration blocks
/*  dynamic "soa_record" {
    for_each = each.value.template.soa_record
    content {
      # Mandatory attributes
      email = soa_record.value["email"]
      # Optional attributes
      expire_time  = var.soa_record.expire_time
      minimum_ttl  = var.soa_record.value["minimum_ttl"], null)
      refresh_time = var.soa_record.value["refresh_time"], null)
      retry_time   = var.soa_record.value["retry_time"], null)
      ttl          = var.soa_record.value["ttl"], null)
    }
  }

  timeouts {
    create = var.resource_custom_timeouts.azurerm_private_dns_zone.create
    update = var.resource_custom_timeouts.azurerm_private_dns_zone.update
    read   = var.resource_custom_timeouts.azurerm_private_dns_zone.read
    delete = var.resource_custom_timeouts.azurerm_private_dns_zone.delete
  }*/

}


# VNet Links
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_vnet_link" {
  for_each = var.private_dns_zone_names

  name                  = "${each.value}-vnetlink"
  resource_group_name   = azurerm_resource_group.dns_rg.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.hub_extension_vnet.id
}




 