variable "client"                 {}
variable "tag_name"               {}
variable "tag_value"              {}
variable "location"               {}
variable "rsg_name"               {}
variable "subnet_id"              {}
variable "gwsubnet_id"            {}
variable "pre_shared_key"         {}
variable "client_gateway_address" {}
variable "client_address_space"   { default = []           }
variable "vpnSku"                 { default = "Basic"      }
variable "vpn_type"               { default = "RouteBased" }

