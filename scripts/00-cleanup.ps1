Write-Host ">>> Iniciando limpieza total del laboratorio..." -ForegroundColor Red

# 1. Detener y desinstalar AdGuard Home
if (Get-Service -Name "AdGuardHome" -ErrorAction SilentlyContinue) {
    Write-Host "Deteniendo AdGuard Home..." -ForegroundColor Yellow
    Stop-Service AdGuardHome -Force -ErrorAction SilentlyContinue
    & "C:\AdGuardHome\AdGuardHome.exe" -s uninstall 2>$null
}
Remove-Item -Path "C:\AdGuardHome" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Detener y limpiar SoftEther VPN
if (Get-Service -Name "sevpnserver" -ErrorAction SilentlyContinue) {
    Write-Host "Deteniendo SoftEther VPN..." -ForegroundColor Yellow
    Stop-Service sevpnserver -Force -ErrorAction SilentlyContinue
}
Remove-Item -Path "C:\openvpn*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\VPN-LAB.ovpn" -Force -ErrorAction SilentlyContinue

# 3. Restaurar Red y Firewall
Write-Host "Restaurando configuraciones de red y firewall..." -ForegroundColor Yellow
Get-NetAdapter | ForEach-Object {
    Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -Dhcp Enabled -ErrorAction SilentlyContinue
    Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
}
netsh advfirewall set allprofiles state off

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "LIMPIEZA COMPLETADA. SERVIDOR LISTO PARA INSTALACION LIMPIA" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
