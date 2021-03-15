resource "azurerm_network_security_group" "ournsgad" {
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
resource "azurerm_network_interface" "ournicad" {
    name                = "${var.computername}-nic"
    location            = "${var.location}"
    resource_group_name = "${var.rsg_name}"
    network_security_group_id = "${azurerm_network_security_group.ournsgad.id}"

    ip_configuration {
        name                          = "${var.computername}-nic-conf"
        subnet_id                     = "${var.subnet_id}"
        private_ip_address_allocation = "static"
        private_ip_address = "${var.ipaddress}"
 #       public_ip_address_id          = "${azurerm_public_ip.ouradpublicip.id}"
    }

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}
#resource "azurerm_public_ip" "ouradpublicip" {
#    name                         = "${var.client}-ad-public-ip"
#    location                     = "${var.location}"
#    resource_group_name          = "${var.rsg_name}"
#    allocation_method            = "Dynamic"

#    tags = "${var.tags}"
#}
resource "azurerm_virtual_machine" "ourvmad" {
    name                  = "${var.computername}"
    location              = "${var.location}"
    resource_group_name   = "${var.rsg_name}"
    network_interface_ids = ["${azurerm_network_interface.ournicad.id}"]
    vm_size               = "${var.serverSize}"

    storage_os_disk {
        name              = "${var.computername}-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "${var.serverSku}"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.computername}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
        custom_data    = file("../modules/files/automate.ps1")
    }

  os_profile_windows_config {
    provision_vm_agent = true
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
    }

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("../modules/files/automate/${var.domain}.xml")
    }
  }

}
