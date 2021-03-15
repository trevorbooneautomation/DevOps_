resource "azurerm_resource_group" "ournewrsg1" {
  name     = var.resourcegroupname
  location = var.resourcegrouplocation
}

resource "azurerm_storage_account" "ournewsa1" {
  name                     = var.storageaccountname
  resource_group_name      = azurerm_resource_group.ournewrsg1.name
  location                 = azurerm_resource_group.ournewrsg1.location
  account_tier             = var.storageaccounttier
  account_replication_type = var.storageaccounttype

     tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
