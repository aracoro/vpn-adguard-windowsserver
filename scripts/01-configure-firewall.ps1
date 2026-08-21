# Reglas para AdGuard Home
New-NetFirewallRule -DisplayName "AdGuard Home - DNS (UDP)" -Direction Inbound -LocalPort 53 -Protocol UDP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "AdGuard Home - DNS (TCP)" -Direction Inbound -LocalPort 53 -Protocol TCP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "AdGuard Home - Web Panel (HTTP)" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "AdGuard Home - Initial Setup" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow -Profile Any

# Reglas para SoftEther VPN Server
New-NetFirewallRule -DisplayName "SoftEther - HTTPS/VPN" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "SoftEther - Management Port" -Direction Inbound -LocalPort 5555 -Protocol TCP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "SoftEther - OpenVPN Port" -Direction Inbound -LocalPort 1194 -Protocol UDP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "SoftEther - IPsec/L2TP IKE" -Direction Inbound -LocalPort 500 -Protocol UDP -Action Allow -Profile Any
New-NetFirewallRule -DisplayName "SoftEther - IPsec/L2TP NAT-T" -Direction Inbound -LocalPort 4500 -Protocol UDP -Action Allow -Profile Any

Write-Host "Reglas de Firewall configuradas con exito." -ForegroundColor Green
