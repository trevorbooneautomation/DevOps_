output "vpn_psk" {
    description = "VPN Pre Shared Key"
    value       = "${var.pre_shared_key}"
}

output "vpn_client_address_space" {
    description = "Client Address Space"
    value       = "${var.client_address_space}"
}

output "vpn_client_gateway_address" {
    description = "Client Gateway Address"
    value       = "${var.client_gateway_address}"
}

output "vpn_type" {
    description = "VPN Type"
    value       = "${var.vpn_type}"
}

output "vpn_sku" {
    description = "VPN Sku"
    value       = "${var.vpnSku}"
}
