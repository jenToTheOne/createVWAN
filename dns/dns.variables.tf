variable "resource_group_location" {
  type        = string
  description = "Location for all resources."
  default     = "westus2"
}

variable "address_space" {
  type        = string
  description = "VNet Address Space."
  default     = "10.100.0.0/16"
}

variable "address_prefix" {
  type        = string
  description = "Subnet Address Prefix."
  default     = "10.100.0.0/24"
}

variable "private_dns_zone_names" {
  type = set(string)
  default = [
    "privatelink.azurecr.io",
    "privatelink.azconfig.io",
    "privatelink.azurewebsites.net",
    "privatelink.siterecovery.windowsazure.com",
    "privatelink.azure-automation.net",
    "privatelink.batch.azure.com",
    "privatelink.search.windows.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.cassandra.cosmos.azure.com",
    "privatelink.documents.azure.com",
    "privatelink.table.cosmos.azure.com",
    "privatelink.adf.azure.com",
    "privatelink.datafactory.azure.net",
    "privatelink.eventgrid.azure.net",
    "privatelink.eventgrid.azure.net",
    "privatelink.servicebus.windows.net",
    "privatelink.afs.azure.net",
    "privatelink.azurehdinsight.net",
    "privatelink.azure-devices.net",
    "privatelink.azure-devices-provisioning.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.api.azureml.ms",
    "privatelink.media.azure.net",
    "privatelink.media.azure.net",
    "privatelink.media.azure.net",
    "privatelink.prod.migration.windowsazure.com",
    "privatelink.monitor.azure.com",             # Private DNS Zone for global endpoints used by Azure Monitor
    "privatelink.oms.opinsights.azure.com",      # Private DNS Zone for workspace-specific mapping to OMS agents endpoints
    "privatelink.ods.opinsights.azure.com",     # Private DNS Zone for workspace-specific mapping to ingestion endpoints
    "privatelink.agentsvc.azure-automation.net", # Private DNS Zone for workspace-specific mapping to the agent service automation endpoints
    "privatelink.redis.cache.windows.net",
    "privatelink.servicebus.windows.net",
    "privatelink.service.signalr.net",
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.web.core.windows.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.webpubsub.azure.com",
    "privatelink.wvd.microsoft.com",
  ]
}