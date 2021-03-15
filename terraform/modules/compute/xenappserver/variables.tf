variable "client"         {}
variable "tag_name"       {}
variable "tag_value"      {}
variable "location"       {}
variable "rsg_name"       {}
variable "subnet_id"      {}
variable "computername"   {}
variable "ipaddress"      {}
variable "serverSize"     { default = "Standard_F4s_v2" }
variable "serverSku"      { default = "2019-Datacenter" }
variable "acl_source_ip"  { default = "1.1.1.1"         }
variable "admin_username" { default = "admin"           }
variable "admin_password" { default = "password"        }
variable "domain"         {}
