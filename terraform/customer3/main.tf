#############################################
#### Azure Customer Main Configuration   ####
#############################################
terraform {
  backend "azurerm" {
  resource_group_name = "Terraform"
  storage_account_name = "terraformstatewest"
  container_name = "tfstate"
  access_key = ""
  key = "compass.tfstate"
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
  client         = "compass"
  address_space  = ["172.16.254.0/24", "172.16.253.0/24","172.16.252.0/24","172.16.251.0/24"]
  main_subnet    = "172.16.253.0/24"
  gateway_subnet = "172.16.254.0/24"
  dns_servers    = ["172.16.253.10","10.0.0.11"]
  domain         = "compassconsult.local"
}
#############################################
####   Client VPN - On Premise to Azure  ####
#############################################
module "vpn_onpremise_azure" {
  source         = "../modules/vpn"
  #  version = "2.0.0"

  # Environment Variables
  client         = module.network.client_name
  location       = module.network.location
  rsg_name       = module.network.rsg_name
  subnet_id      = module.network.oursubnet
  gwsubnet_id    = module.network.ourgwsubnet
  tags           = module.network.tags

  # VPN Configuration
  # Client On Premise - Peer IP Example 4.10.11.26
  client_gateway_address = "5.18.11.26"
  # Client On Premise - Subnets Example: ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  client_address_space   = ["10.0.0.0/16"]
  # VPN Sku/Type
  vpnSku                 = "Basic"
  vpn_type               = "PolicyBased"
  pre_shared_key         = ""
}
##############################################
####        AD AND FS Server              ####
##############################################
module "activedirectory" {
  source          = "../modules/compute/adserver"

  # Environment Variables
  client         = module.network.client_name
  location       = module.network.location
  rsg_name       = module.network.rsg_name
  subnet_id      = module.network.oursubnet
  tags           = module.network.tags
  domain         = module.network.domain

 # Server Variables
  computername   = "cc-az-adfs-01"
  ipaddress      = "172.16.253.10"
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
  subnet_id      = module.network.oursubnet
  tags           = module.network.tags
  domain         = module.network.domain
 
 # Server Variables
  computername   = "cc-az-xa-01"
  ipaddress      = "172.16.253.12"
  serverSize     = "Standard_F4s_v2"
  serverSku      = "2019-Datacenter"

}
##############################################
####            Storage Account           ####
##############################################
module "storage1" {
  source                 = "../modules/storageaccount"

  #Variables
   resourcegroupname     = "devops"
   resourcegrouplocation = "westus"
   storageaccountname    = "ccdevopsfiles"
   storageaccounttag     = "storage"

}
