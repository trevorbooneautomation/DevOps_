variable "location" {
    description = "The location of resource in Azure"
    default = "westus"
}

variable "client" {
    description = "Client Name"
}

variable "subnet_name" {
    description = "New Subnet Name"
}

variable "subnet_address" {
    description = "New Subnet Address"
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
