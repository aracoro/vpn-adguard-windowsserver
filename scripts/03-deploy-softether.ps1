Write-Host "Descargando SoftEther VPN Server..." -ForegroundColor Cyan

$Installer = "$env:TEMP\softether.exe"
$Url = "https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.43-9799-beta/softether-vpnserver_vpnbridge-v4.43-9799-beta-2023.06.30-windows-x86_x64-intel.exe"

# Descarga directa con curl
curl.exe -L -o $Installer $Url

if (Test-Path $Installer) {
    Write-Host "Instalando servicio..." -ForegroundColor Cyan
    Start-Process -FilePath $Installer -ArgumentList "/VERYSILENT /SP- /NORESTART" -Wait
    Remove-Item $Installer -Force

    Start-Service -Name "sevpnserver" -ErrorAction SilentlyContinue

    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "SoftEther VPN Server instalado y corriendo correctamente." -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host "Error: No se descargo el archivo." -ForegroundColor Red
}
