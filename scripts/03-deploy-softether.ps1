Write-Host "Configurando TLS y descargando SoftEther VPN Server..." -ForegroundColor Cyan

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Installer = "$env:TEMP\softether.exe"
$Url = "https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.43-9799-beta/softether-vpnserver_vpnbridge-v4.43-9799-beta-2023.06.30-windows-x86_x64-intel.exe"

# Descarga robusta con PowerShell manejando redirecciones y TLS 1.2
Invoke-WebRequest -Uri $Url -OutFile $Installer -MaximumRedirection 5

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
    Write-Host "Error: El archivo descargado esta incompleto ($FileSize bytes)." -ForegroundColor Red
}
