Write-Host ">>> [Fix v3] Aplicando configuracion de red con netsh..." -ForegroundColor Cyan

# 1. Desactivar colisiones DAD por Wi-Fi
Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4 -DadTransmits 0 -ErrorAction SilentlyContinue

# 2. Forzar IP estatica, mascara y Gateway de forma atomica
netsh interface ipv4 set address name="Ethernet" source=static address=192.168.1.176 mask=255.255.255.0 gateway=192.168.1.254

# 3. Asignar servidores DNS
netsh interface ipv4 set dns name="Ethernet" source=static address=1.1.1.1
netsh interface ipv4 add dns name="Ethernet" address=8.8.8.8 index=2

# 4. Apagar firewall para el entorno de laboratorio
netsh advfirewall set allprofiles state off

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Configuracion aplicada. Validando tabla IP:" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

ipconfig
