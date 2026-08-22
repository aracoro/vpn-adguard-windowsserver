Write-Host "Limpiando configuracion de red y asignando nueva IP estatica..." -ForegroundColor Cyan

# 1. Eliminar IPs IPv4 anteriores
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false

# 2. Asignar nueva IP limpia para evitar conflicto DAD
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.220 -PrefixLength 24 -DefaultGateway 192.168.1.254

# 3. DNS de salida
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1", "8.8.8.8")

# 4. Desactivar Firewall para pruebas
netsh advfirewall set allprofiles state off

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Verificando configuracion IP:" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

ipconfig
