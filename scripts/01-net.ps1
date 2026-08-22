Write-Host ">>> Aplicando reinicio y configuracion IP con netsh..." -ForegroundColor Cyan

# 1. Pasar a DHCP momentaneamente para purgar rutas y gateways colgados
netsh interface ipv4 set address name="Ethernet" source=dhcp
netsh interface ipv4 set dnsservers name="Ethernet" source=dhcp
Start-Sleep -Seconds 2

# 2. Asignar IP estatica, mascara y Gateway
netsh interface ipv4 set address name="Ethernet" static 192.168.1.176 255.255.255.0 192.168.1.254 1

# 3. Asignar servidores DNS
netsh interface ipv4 set dns name="Ethernet" static 1.1.1.1 primary
netsh interface ipv4 add dns name="Ethernet" 8.8.8.8 index=2

# 4. Desactivar colisiones DAD por Wi-Fi
Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv4 -DadTransmits 0 -ErrorAction SilentlyContinue

# 5. Desactivar Firewall para pruebas
netsh advfirewall set allprofiles state off

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Configuracion completada. Validando adaptador:" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

ipconfig
