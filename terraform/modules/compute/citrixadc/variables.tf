variable "client"         {}
variable "tag_name"       {}
variable "tag_value"      {}
variable "location"       {}
variable "rsg_name"       {}
variable "subnet_id"      {}
variable "computername"   {}
variable "ipaddress"      {}
variable "serverSize"     { default = "Standard_B2ms"        }
variable "ServerOffer"    { default = "netscalervpx-130"     }
variable "serverSku"      { default = "netscalerbyol"        }
variable "acl_source_ip"  { default = ["4.80.61.26"]         }
variable "admin_username" { default = "admin"                }
variable "admin_password" { default = "password"             }
variable "domain"         {}
