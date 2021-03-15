variable "location" {
    description = "The location of resource in Azure"
    default = "westus"
}

variable "client" {
    description = "Client Name"
}

variable "tag_name" {
}

variable "tag_value" {
}

variable "nsg_name" {
    description = "NSG Name"
}

variable "nsg_priority" {
}

variable "nsg_direction" {
    description = "Direction: Inbound or Outbound"
}

variable "access" {
    description = "Allow or Deny"
}
 
variable "protocol" {
    description = "Tcp, Udp, Both"
}

variable "source_port_ranges" {
    description = "Source Port Ranges - 12-50,12,128 etc"
}

variable "destination_port_ranges" {
    description = "Destination Port Ranges - 12-50,12,128 etc"
}

variable "source_address_prefixes" {
    description = "Source Addresses - 10.20.0.1,10.200.20.0/24,10.10.10.10"
    default = []
}

variable "destination_address_prefixes" {
    description = "Destination Addresses - 10.20.0.1,10.200.20.0/24,10.10.10.10"
    default = []
}

variable "subnet_id" {
    description = "Subnet ID from whatever Subnet you are using"
}
