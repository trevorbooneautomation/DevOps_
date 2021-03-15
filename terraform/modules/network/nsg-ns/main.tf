resource "azurerm_network_security_group" "nsg1" {
  name                = "${var.nsg_name}-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.client}-resource-group"
    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }

  security_rule {
    name                         = "${var.nsg_name}"
    priority                     = "${var.nsg_priority}"
    direction                    = "${var.nsg_direction}"
    access                       = "${var.access}"
    protocol                     = "${var.protocol}"
    source_port_ranges           = "${var.source_port_ranges}"
    destination_port_ranges      = "${var.destination_port_ranges}"
    source_address_prefixes      = "${var.source_address_prefixes}"
    destination_address_prefixes = "${var.destination_address_prefixes}"
  }
}


resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = "${var.subnet_id}"
  network_security_group_id = azurerm_network_security_group.nsg1.id
}
