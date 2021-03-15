## NETWORK DEPLOYMENT
## 1. Resource Group
## 2. Virtual Network
##   a. Address Space
##   b. Subnet

## 1.
resource "azurerm_resource_group" "ourresourcegroup" {
    name     = "${var.client}-resource-group"
    location = "${var.location}"
    tags = {
	"${var.tag_name}" = "${var.tag_value}"
	}
}

## 2.
resource "azurerm_virtual_network" "ournetwork" {
    name                = "${var.client}-vnet"
    address_space       = "${var.address_space}"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.ourresourcegroup.name}"
    dns_servers         = "${var.dns_servers}"
    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}

## 3.
resource "azurerm_subnet" "oursubnet" {
    name                 = "${var.client}-subnet"
    resource_group_name  = "${azurerm_resource_group.ourresourcegroup.name}"
    virtual_network_name = "${azurerm_virtual_network.ournetwork.name}"
    address_prefix       = "${var.main_subnet}"
}

resource "azurerm_subnet" "ourgwsubnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = "${azurerm_resource_group.ourresourcegroup.name}"
    virtual_network_name = "${azurerm_virtual_network.ournetwork.name}"
    address_prefix       = "${var.gateway_subnet}"
}

output "domain" {
  value       = "${var.domain}"
  description = "Domain of Client."
}
