variable "client"         {}
variable "tag_name"       {}
variable "tag_value"      {}
variable "location"       {}
variable "rsg_name"       {}
variable "subnet_id"      {}
variable "computername"   {}
variable "ipaddress"      {}
variable "serverSize"     { default = "Standard_B2ms"                }
variable "serverSku"      { default = "2019-Datacenter-Core"         }
variable "acl_source_ip"  { default = ["7.80.11.26","1.2.3.4"]       }
variable "admin_username" { default = "admin"                        }
variable "admin_password" { default = "password"                     }
variable "domain"         {}
