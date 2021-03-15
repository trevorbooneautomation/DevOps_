output "subnet" {
    description = "Our Subnet"
    value       = "${azurerm_subnet.oursubnet-as.id}"
}
