# ===================================================================
# 00-set-static-ip.ps1 - Fijar IP estática en Windows Server
# ===================================================================

$interfaz = (Get-NetAdapter | Where-Object Status -eq 'Up').Name

Write-Host "Configurando IP estatica en interfaz: $interfaz" -ForegroundColor Cyan

# Asignar IP fija, mascara /24 y Gateway
New-NetIPAddress -InterfaceAlias $interfaz -IPAddress 192.168.1.176 -PrefixLength 24 -DefaultGateway 192.168.1.254 -ErrorAction SilentlyContinue

# Configurar DNS local para resolver con AdGuard
Set-DnsClientServerAddress -InterfaceAlias $interfaz -ServerAddresses ("127.0.0.1", "1.1.1.1")

Write-Host "IP 192.168.1.176 fijada correctamente." -ForegroundColor Green
