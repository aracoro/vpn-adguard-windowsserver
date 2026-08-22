Write-Host "Desactivando DAD y forzando IP estatica 192.168.1.176..." -ForegroundColor Cyan

# 1. Desactivar deteccion DAD para evitar conflictos falsos por Wi-Fi
Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4 -DadTransmits 0

# 2. Limpiar e inyectar IP estatica
Remove-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.176 -PrefixLength 24 -DefaultGateway 192.168.1.254 -SkipAsSource $false

# 3. DNS de salida
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1", "8.8.8.8")

# 4. Apagar firewall
netsh advfirewall set allprofiles state off

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Estado actual de la interfaz:" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

ipconfig
