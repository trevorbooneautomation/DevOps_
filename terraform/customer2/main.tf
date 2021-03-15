#############################################
#### Azure Customer Main Configuration   ####
#############################################
terraform {
  backend "azurerm" {
  resource_group_name = "Terraform"
  storage_account_name = "terraformstatewest"
  container_name = "tfstate"
  access_key = ""
  key = "citihosts.tfstate"
 }
}
provider "azurerm" {
  version         = "=1.35.0"
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
}
#############################################
#### Client Network / Azure Configuration####
#############################################
module "network" {
  source         = "../modules/network"
  #  version = "2.0.0"
  # Environment Variables Defined
  location       = "westus"
  client         = "CitihostsNetwork"
  address_space  = ["10.222.0.0/16"]
  main_subnet    = "10.222.1.0/24"
  gateway_subnet = "10.222.0.0/29"
  dns_servers    = ["10.222.2.10","1.1.1.1"]
  domain         = "citihosts.local"
  tag_name       = "BILLING"
  tag_value      = "CITIHOSTS"

}
#############################################
####   Client VPN - On Premise to Azure  ####
#############################################
#module "vpn_onpremise_azure" {
#  source         = "../modules/vpn"
  #  version = "2.0.0"

  # Environment Variables
#  client         = module.network.client_name
#  location       = module.network.location
#  rsg_name       = module.network.rsg_name
#  subnet_id      = module.network.oursubnet
#  gwsubnet_id    = module.network.ourgwsubnet
#  tag_name       = module.network.tag_name
#  tag_value      = module.network.tag_value

  # VPN Configuration
  # Client On Premise - Peer IP Example 4.10.16.226
#  client_gateway_address = "1.10.161.235"
  # Client On Premise - Subnets Example: ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
#  client_address_space   = ["10.64.0.0/24", "10.64.1.0/24", "10.64.2.0/24"]
  # VPN Sku/Type
#  vpnSku                 = "Basic"
#  vpn_type               = "RouteBased"
#  pre_shared_key         = ""
#}
#############################################
####       Add a Client Subnet           ####
#############################################
module "addsubnet1" {
  source          = "../modules/network/add-subnet"

  # Environment Variables
  client         = module.network.client_name
  location       = module.network.location
  domain         = module.network.domain
  address_space  = module.network.address_space

  subnet_name    = "Citihosts-DMZ-West"
  subnet_address = "10.222.254.0/27"

}
#############################################
####       Add a Client NSG              ####
#############################################                                                                                                                           module "addsubnet2" {
module "addnsg1" {
  source          = "../modules/network/nsg"

  # Environment Variables
  client         = module.network.client_name
  location       = module.network.location
  subnet_id      = module.addsubnet1.subnet
  tag_name       = module.network.tag_name
  tag_value      = module.network.tag_value

  nsg_name                     = "DMZ"
  nsg_priority                 = "100"
  nsg_direction                = "Outbound"
  access                       = "Deny"
  protocol                     = "*"
  source_port_ranges           = ["*"]
  destination_port_ranges      = ["*"]
  source_address_prefixes      = ["*"]
  destination_address_prefixes = ["10.222.0.0/16"]

}
