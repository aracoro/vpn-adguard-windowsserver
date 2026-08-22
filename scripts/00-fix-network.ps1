Write-Host "Restableciendo adaptador de red y fijando IP estatica..." -ForegroundColor Cyan

# 1. Limpiar IPs IPv4 previas
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false

# 2. Reiniciar interfaz de red
Restart-NetAdapter -Name "Ethernet"
Start-Sleep -Seconds 3

# 3. Asignar IP fija, mascara y Gateway
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.176 -PrefixLength 24 -DefaultGateway 192.168.1.254 -ErrorAction SilentlyContinue

# 4. Configurar servidores DNS de salida
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1", "8.8.8.8")

# 5. Deshabilitar Firewall temporalmente para pruebas de laboratorio
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Red configurada en 192.168.1.176. Validando estado..." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

ipconfig
