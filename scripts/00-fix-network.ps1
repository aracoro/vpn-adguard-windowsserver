Write-Host "Limpiando rutas, IPs previas y configurando IP estatica..." -ForegroundColor Cyan

# 1. Limpiar rutas por defecto (Gateway) y direcciones IPv4 existentes
Get-NetRoute -InterfaceAlias "Ethernet" -DestinationPrefix "0.0.0.0/0" -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetRoute -Confirm:$false
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false

# 2. Desactivar deteccion DAD para evitar bloqueos por Wi-Fi
Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4 -DadTransmits 0

# 3. Asignar IP estatica y Puerta de enlace limpias
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.176 -PrefixLength 24 -DefaultGateway 192.168.1.254

# 4. Servidores DNS publicos
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1", "8.8.8.8")

# 5. Desactivar Firewall para el laboratorio
netsh advfirewall set allprofiles state off

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Configuracion aplicada con exito:" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

ipconfig
