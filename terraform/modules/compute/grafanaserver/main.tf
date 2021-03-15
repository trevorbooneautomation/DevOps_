resource "azurerm_network_security_group" "ournsgxa" {
    name                = "${var.computername}-nsg"
    location            = "${var.location}"
    resource_group_name = "${var.rsg_name}"

    security_rule {
        name                       = "SSH"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range    = "22"
        source_address_prefixes      = ["${var.acl_source_ip}", "47.180.162.254"]
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "GrafanWebpage"
        priority                   = 310
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.dest_port}"
        source_address_prefix      = "${var.acl_source_ip}"
        destination_address_prefix = "*"
    }

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
resource "azurerm_network_interface" "ournicxa" {
    name                = "${var.computername}-nic"
    location            = "${var.location}"
    resource_group_name = "${var.rsg_name}"
    network_security_group_id = "${azurerm_network_security_group.ournsgxa.id}"

    ip_configuration {
        name                          = "${var.computername}-nic-conf"
        subnet_id                     = "${var.subnet_id}"
        private_ip_address_allocation = "Static"
        private_ip_address            = "${var.ipaddress}"
        public_ip_address_id          = "${azurerm_public_ip.ourpublicip.id}"
    }

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
resource "azurerm_public_ip" "ourpublicip" {
    name                         = "${var.client}-xa-public-ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.rsg_name}"
    allocation_method            = "Dynamic"

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
resource "azurerm_virtual_machine" "ourvmxa" {
    name                  = "${var.computername}"
    location              = "${var.location}"
    resource_group_name   = "${var.rsg_name}"
    network_interface_ids = ["${azurerm_network_interface.ournicxa.id}"]
    vm_size               = "${var.serverSize}"

    storage_os_disk {
        name              = "${var.computername}-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.computername}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

   os_profile_linux_config {
    disable_password_authentication = false
  }
}
