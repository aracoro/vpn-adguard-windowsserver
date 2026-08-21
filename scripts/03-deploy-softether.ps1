Write-Host "Configurando TLS y descargando SoftEther VPN Server (Estable)..." -ForegroundColor Cyan

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Installer = "$env:TEMP\softether.exe"
$Url = "https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.38-9760-rtm/softether-vpnserver_vpnbridge-v4.38-9760-rtm-2021.08.17-windows-x86_x64-intel.exe"

# Descarga directa con curl y seguimiento de redirecciones
curl.exe -L -k -o $Installer $Url

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
    Write-Host "Error: No se pudo descargar el archivo ($FileSize bytes)." -ForegroundColor Red
}
