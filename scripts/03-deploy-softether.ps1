Write-Host "Descargando instalador de SoftEther VPN Server (50MB)..." -ForegroundColor Cyan

$Installer = "$env:TEMP\softether.exe"
$Url = "https://www.softether-download.com/files/softether/v4.43-9799-beta-2023.06.30-tree/Windows/SoftEther_VPN_Server_and_VPN_Bridge/softether-vpnserver_vpnbridge-v4.43-9799-beta-2023.06.30-windows-x86_x64-intel.exe"

# Descarga directa con soporte de redirecciones
curl.exe -L -k -A "Mozilla/5.0" -o $Installer $Url

$FileSize = (Get-Item $Installer -ErrorAction SilentlyContinue).Length

if ($FileSize -gt 10000000) {
    Write-Host "Descarga exitosa ($([math]::Round($FileSize/1MB, 2)) MB). Instalando..." -ForegroundColor Cyan
    Start-Process -FilePath $Installer -ArgumentList "/VERYSILENT /SP- /NORESTART" -Wait
    Remove-Item $Installer -Force

    Start-Service -Name "sevpnserver" -ErrorAction SilentlyContinue

    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "SoftEther VPN Server instalado y corriendo correctamente." -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "Error: El archivo descargado esta incompleto o corrupto ($FileSize bytes)." -ForegroundColor Red
}
