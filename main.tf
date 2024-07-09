
resource "azurerm_resource_group" "rg" {
  name     = "rg_vwan_tf"
  location = var.resource_group_location
}

resource "azurerm_virtual_wan" "azfw_vwan" {
  name                           = "vwan-azfw-securehub-weus"
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  allow_branch_to_branch_traffic = true
  disable_vpn_encryption         = false
}

resource "azurerm_virtual_hub" "azfw_vwan_hub_westus" {
  name                = "hub-azfw-securehub-weus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  virtual_wan_id      = azurerm_virtual_wan.azfw_vwan.id
  address_prefix      = "10.20.0.0/23"
}

resource "azurerm_virtual_hub" "azfw_vwan_hub_uksouth" {
  name                = "hub-azfw-securehub-uksouth"
  location            = var.hub2_location
  resource_group_name = azurerm_resource_group.rg.name
  virtual_wan_id      = azurerm_virtual_wan.azfw_vwan.id
  address_prefix      = "10.30.0.0/23"
}

#Firewall - Hub 1
resource "azurerm_firewall" "fw-westus" {
  name                = "fw-azfw-securehub-weus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_name
  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.azfw_vwan_hub_westus.id
    public_ip_count = 1
  }
  firewall_policy_id = azurerm_firewall_policy.azfw_policy_weus.id
  zones = [ "1","2","3" ]
}

#Firewall - Hub 2
resource "azurerm_firewall" "fw-uksouth" {
  name                = "fw-azfw-securehub-uksouth"
  location            = var.hub2_location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_name
  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.azfw_vwan_hub_uksouth.id
    public_ip_count = 1
  }
  firewall_policy_id = azurerm_firewall_policy.azfw_policy_uksouth.id
  zones = [ "1","2","3" ]
}

#Routing Intent - Hub 1
resource "azurerm_virtual_hub_routing_intent" "azfw_vwan_hub_routing_intent_hub1" {
  name           = "azfw_vwan_hub_routing_intent"
  virtual_hub_id = azurerm_virtual_hub.azfw_vwan_hub_westus.id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["Internet"]
    next_hop     = azurerm_firewall.fw-westus.id
  }

  routing_policy {
    name         = "PrivateTrafficPolicy"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_firewall.fw-westus.id
  }
}

#Routing Intent - Hub 2
resource "azurerm_virtual_hub_routing_intent" "azfw_vwan_hub_routing_intent_hub2" {
  name           = "azfw_vwan_hub_routing_intent"
  virtual_hub_id = azurerm_virtual_hub.azfw_vwan_hub_uksouth.id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["Internet"]
    next_hop     = azurerm_firewall.fw-uksouth.id
  }

  routing_policy {
    name         = "PrivateTrafficPolicy"
    destinations = ["PrivateTraffic"]
    next_hop     = azurerm_firewall.fw-uksouth.id
  }
}

#Azure Policy - Hub 1
resource "azurerm_firewall_policy" "azfw_policy_weus" {
  name                     = "policy-azfw-securehub-weus"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = var.firewall_sku_name
  threat_intelligence_mode = "Alert"
}

resource "azurerm_firewall_policy_rule_collection_group" "app_policy_rule_collection_group_weus" {
  name               = "DefaulApplicationtRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy_weus.id
  priority           = 300
  application_rule_collection {
    name     = "DefaultApplicationRuleCollection"
    action   = "Allow"
    priority = 100
    rule {
      name        = "Allow-MSFT"
      description = "Allow access to Microsoft.com"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      destination_fqdns = ["*.microsoft.com"]
      terminate_tls     = false
      source_addresses  = ["*"]
    }
  }
}

#Azure Policy - Hub 2
resource "azurerm_firewall_policy" "azfw_policy_uksouth" {
  name                     = "policy-azfw-securehub-uksouth"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.hub2_location
  sku                      = var.firewall_sku_name
  threat_intelligence_mode = "Alert"
}

resource "azurerm_firewall_policy_rule_collection_group" "app_policy_rule_collection_group_uksouth" {
  name               = "DefaulApplicationtRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy_uksouth.id
  priority           = 300
  application_rule_collection {
    name     = "DefaultApplicationRuleCollection"
    action   = "Allow"
    priority = 100
    rule {
      name        = "Allow-MSFT"
      description = "Allow access to Microsoft.com"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      destination_fqdns = ["*.microsoft.com"]
      terminate_tls     = false
      source_addresses  = ["*"]
    }
  }
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

locals {
  dns_all = {for idx, dns_location in var.dns-locations: 
            dns_location => {
              resource_group_location = dns_location
              address_space  = var.dns-vnets[idx]
              address_prefix  = var.dns-subnets[idx]
            }
           }
}

module "dns" {
  source = "./dns"

  for_each = local.dns_all

  resource_group_location = each.value.resource_group_location
  address_prefix = each.value.address_prefix
  address_space = each.value.address_space

}