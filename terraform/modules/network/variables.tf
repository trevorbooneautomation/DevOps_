variable "tag_name" {

}

variable "tag_value" {

}

variable "location" {
    description = "The location of resource in Azure"
    default = "westus" 
}

variable "client" {
    description = "Client Name"
}

variable "main_subnet" {
    description = "Client Main Subnet"
}

variable "gateway_subnet" {
    description = "Gateway Subnet"
}

variable "tags" {
    description = "Variable Tags"
    type = "map"
    default = {
        environment = "azure customer deploy"
    }
}

variable "address_space" { 
    description = "Virtual Network Address Space"
    default = [] 
}

variable "dns_servers" { 
    description = "DNS Servers"
    default = [] 
}

variable "domain" {
    description = "Active Directory Domain Suffix"
    type = "string"
}
