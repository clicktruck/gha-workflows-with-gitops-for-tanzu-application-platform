variable "domain" {
  description = "The base domain where an NS recordset will be added mirroring a new sub-domain's recordset"
}

variable "resource_group_name" {
  description = "A name for a resource group; @see https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group"
}
