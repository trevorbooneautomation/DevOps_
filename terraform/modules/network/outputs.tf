output "rsg_name" {
    description = "The resource group name"
    value       = "${azurerm_resource_group.ourresourcegroup.name}"
}

output "vnet_name" {
    description = "Virtual Network name"
    value       = "${azurerm_virtual_network.ournetwork.name}"
}

output "address_space" {
    description = "Virtual Network Address Space"
    value       = "${azurerm_virtual_network.ournetwork.address_space}"
}

output "client_name" {
    description = "Client Name"
    value       = "${var.client}"
}

output "tag_name" {
    description = "Tag Name"
    value       = "${var.tag_name}"
}

output "tag_value" {
    description = "Tag Value"
    value       = "${var.tag_value}"
}

output "location" {
    description = "Location"
    value       = "${var.location}"
}

output "dns_servers" {
    description = "DNS Servers"
    value       = "${var.dns_servers}"
}

output "subnet" {
    description = "Our Subnet"
    value       = "${azurerm_subnet.oursubnet.id}"
}

output "ourgwsubnet" {
    description = "Our GW Subnet"
    value       = "${azurerm_subnet.ourgwsubnet.id}"
}
