variable "client"         {}
variable "tag_name"       {}
variable "tag_value"      {}
variable "location"       {}
variable "rsg_name"       {}
variable "subnet_id"      {}
variable "computername"   {}
variable "ipaddress"      {}
variable "serverSize"     { default = "Standard_D2s_v3" }
variable "acl_source_ip"  { default = "1.1.1.1"         }
variable "admin_username" { default = "admin"           }
variable "admin_password" { default = "password"        }
