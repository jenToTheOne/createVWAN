variable "resource_group_location" {
  type        = string
  description = "Location for all resources."
  default     = "westus2"
}

variable "hub2_location" {
  type        = string
  description = "Location for all resources."
  default     = "uksouth"
}

variable "dns-locations" {
  default = [ "westus2","uksouth" ]
}

variable "dns-vnets" {
  default = [ "10.100.0.0/16","10.200.0.0/16" ]
}

variable "dns-subnets" {
  default = [ "10.100.0.0/24","10.200.0.0/24" ]
}

variable "resource_group_name_prefix" {
  type = string
  description = "Prefix for the Resource Group Name that's combined with a random id so name is unique in your Azure subcription."  
  default = "rg"
}

variable "firewall_sku_name" {
  type        = string
  description = "SKU name for the firewall."
  default     = "Premium" # Valid values are Standard and Premium
}

variable "virtual_machine_size" {
  type        = string
  description = "Size of the virtual machine."
  default     = "Standard_D2_v3"
}

variable "admin_username" {
  default = "azureuser"
}
