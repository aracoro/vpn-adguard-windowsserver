# ===================================================================
# 03-deploy-softether.ps1 - Instalación de SoftEther VPN Server
# ===================================================================

Write-Host "Descargando e instalando SoftEther VPN Server..." -ForegroundColor Cyan

$Url = "https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.43-9799-beta/softether-vpnserver_vpnbridge-v4.43-9799-beta-2023.06.30-windows-x86_x64-intel.exe"
$Installer = "$env:TEMP\softether-vpnserver.exe"

# Descarga del ejecutable
Invoke-WebRequest -Uri $Url -OutFile $Installer

# Instalación desatendida / silenciosa
Start-Process -FilePath $Installer -ArgumentList "/VERYSILENT /SP- /NORESTART" -Wait
Remove-Item $Installer

# Iniciar el servicio
Start-Service -Name "sevpnserver" -ErrorAction SilentlyContinue

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "SoftEther VPN Server instalado y en ejecucion." -ForegroundColor Green
Write-Host "Gestionable desde tu PC en el puerto 5555 / 443" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
