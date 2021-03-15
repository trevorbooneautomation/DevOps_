#############################################
#### Azure Customer Main Configuration   ####
#############################################
terraform {
  backend "azurerm" {
  resource_group_name = "Terraform"
  storage_account_name = "terraformstatewest"
  container_name = "tfstate"
  access_key = ""
  key = "testenv.tfstate"
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
  client         = "testClient"
  address_space  = ["10.150.32.0/20"]
  main_subnet    = "10.150.33.0/24"
  gateway_subnet = "10.150.32.0/24"
  dns_servers    = ["10.150.33.10","1.1.1.1"]
  domain         = "domain.local"
  tag_name       = "TEST"
  tag_value      = "TEST"

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
##############################################
####              AD Server               ####
##############################################
module "activedirectory" {
  source          = "../modules/compute/adserver"

  # Environment Variables
  client         = module.network.client_name
  location       = module.network.location
  rsg_name       = module.network.rsg_name
  subnet_id      = module.network.subnet
  domain         = module.network.domain
  tag_name       = module.network.tag_name
  tag_value      = module.network.tag_value

 # Server Variables
  computername   = "testenvAd01"
  ipaddress      = "10.150.33.10"
  serverSize     = "Standard_B2ms"
  serverSku      = "2019-Datacenter-Core"

}
##############################################
####              AD Server               ####
##############################################
module "activedirectory2" {
  source          = "../modules/compute/adserver"

  # Environment Variables
  client         = module.network.client_name
  location       = module.network.location
  rsg_name       = module.network.rsg_name
  subnet_id      = module.network.subnet
  domain         = module.network.domain
  tag_name       = module.network.tag_name
  tag_value      = module.network.tag_value

 # Server Variables
  computername   = "testenvAd02"
  ipaddress      = "10.150.33.20"
  serverSize     = "Standard_B2ms" 
  serverSku      = "2019-Datacenter-Core"

}
##############################################
####            XenApp Server             ####
##############################################
module "xenapp" {
  source          = "../modules/compute/xenappserver"
  
  # Environment Variables
  client         = module.network.client_name
  location       = module.network.location
  rsg_name       = module.network.rsg_name
  subnet_id      = module.network.subnet
  domain         = module.network.domain
  tag_name       = module.network.tag_name
  tag_value      = module.network.tag_value
 
 # Server Variables
  computername   = "testenvXa01"
  ipaddress      = "10.150.33.11"
  serverSize    = "Standard_B2ms"
#  serverSize     = "Standard_F4s_v2"
  serverSku      = "2019-Datacenter"
 
}
##############################################
####             File Server              ####
##############################################
#module "fileserver" {
#  source          = "../modules/compute/fileserver"

  # Environment Variables
#  client         = module.network.client_name
#  location       = module.network.location
#  rsg_name       = module.network.rsg_name
#  subnet_id      = module.network.subnet
#  tag_name       = module.network.tag_name
#  tag_value      = module.network.tag_value

 # Server Variables
#  computername   = "testenvFs01"
#  ipaddress      = "10.150.33.12"
#  serverSize     = "Standard_B2ms"
#  serverSize     = "Standard_F4s_v2"
#  serverSku      = "2019-Datacenter-Core"

#}
##############################################
