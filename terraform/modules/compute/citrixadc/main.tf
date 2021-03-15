resource "azurerm_network_security_group" "ournsgcitrixadc" {
    name                = "${var.computername}-nsg"
    location            = "${var.location}"
    resource_group_name = "${var.rsg_name}"

    security_rule {
        name                       = "RemoteDesktop"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefixes    = "${var.acl_source_ip}"
        destination_address_prefix = "*"
    }

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
resource "azurerm_network_interface" "ourniccitrixadc" {
    name                = "${var.computername}-nic"
    location            = "${var.location}"
    resource_group_name = "${var.rsg_name}"
    network_security_group_id = "${azurerm_network_security_group.ournsgcitrixadc.id}"

    ip_configuration {
        name                          = "${var.computername}-nic-conf"
        subnet_id                     = "${var.subnet_id}"
        private_ip_address_allocation = "static"
        private_ip_address = "${var.ipaddress}"
        public_ip_address_id          = "${azurerm_public_ip.ourcitrixadcpublicip.id}"
    }

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
resource "azurerm_public_ip" "ourcitrixadcpublicip" {
    name                         = "${var.client}-ad-public-ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.rsg_name}"
    allocation_method            = "Dynamic"

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
resource "azurerm_virtual_machine" "ourvmcitrixadc" {
    name                  = "${var.computername}"
    location              = "${var.location}"
    resource_group_name   = "${var.rsg_name}"
    network_interface_ids = ["${azurerm_network_interface.ourniccitrixadc.id}"]
    vm_size               = "${var.serverSize}"

    storage_os_disk {
        name              = "${var.computername}-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    plan {
        name      = "${var.serverSku}"
        product   = "${var.ServerOffer}"
        publisher = "citrix"
    }

    storage_image_reference {
        publisher = "citrix"
        offer     = "${var.ServerOffer}"
        sku       = "${var.serverSku}"
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
