resource "azurerm_subnet" "oursubnet-as" {
    name                 = "${var.subnet_name}-subnet"
    resource_group_name  = "${var.client}-resource-group"
    virtual_network_name = "${var.client}-vnet"
    address_prefix       = "${var.subnet_address}"
}

output "domain" {
  value       = "${var.domain}"
  description = "Domain of Client."
}
