## VPN DEPLOYMENT
## 1. Public IP
## 2. Local Network Gateway (On Premise)
## 3. Azure Network Gateway (Azure)
## 4. VPN Connect

## 1.
resource "azurerm_public_ip" "ourgwpublicip" {
    name                         = "${var.client}-gateway-public-ip"
    location                     = "${var.location}"
    resource_group_name          = "${var.rsg_name}"
    allocation_method            = "Dynamic"

    tags = {
        "${var.tag_name}" = "${var.tag_value}"
        }
}

## 2.
resource "azurerm_local_network_gateway" "clientvirtualgateway" {
  name                = "${var.client}-local-gateway"
  location            = "${var.location}"
  resource_group_name = "${var.rsg_name}"
  gateway_address     = "${var.client_gateway_address}"
  address_space       = "${var.client_address_space}"
}

## 3.
resource "azurerm_virtual_network_gateway" "ourvirtualgateway" {
  name                = "${var.client}-virtual-gateway"
  location            = "${var.location}"
  resource_group_name = "${var.rsg_name}"

  type     = "Vpn"
  vpn_type = "${var.vpn_type}"

  active_active = false
  enable_bgp    = false
  sku           = "${var.vpnSku}"

  ip_configuration {
    name                          = "${var.client}-gateway-ip-config"
    public_ip_address_id          = "${azurerm_public_ip.ourgwpublicip.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${var.gwsubnet_id}"
  }

#  vpn_client_configuration {
#    address_space = ["10.254.5.0/24"]
# }
}

## 4.
resource "azurerm_virtual_network_gateway_connection" "ourvpnconnection" {
  name                = "${var.client}-S2S"
  location            = "${var.location}"
  resource_group_name = "${var.rsg_name}"

  type                       = "IPsec"
  virtual_network_gateway_id = "${azurerm_virtual_network_gateway.ourvirtualgateway.id}"
  local_network_gateway_id   = "${azurerm_local_network_gateway.clientvirtualgateway.id}"

  shared_key = "${var.pre_shared_key}"
}

