# ===================================================================
# 02-deploy-adguard.ps1 - Instalación de AdGuard Home
# ===================================================================

Write-Host "Descargando e instalando AdGuard Home..." -ForegroundColor Cyan

$AdGuardUrl = "https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_windows_amd64.zip"
$ZipPath = "$env:TEMP\AdGuardHome.zip"
$DestPath = "C:\"

# Descargar y descomprimir
Invoke-WebRequest -Uri $AdGuardUrl -OutFile $ZipPath
Expand-Archive -Path $ZipPath -DestinationPath $DestPath -Force
Remove-Item $ZipPath

# Instalar e iniciar como servicio
Set-Location "C:\AdGuardHome"
.\AdGuardHome.exe -s install
.\AdGuardHome.exe -s start

# Obtener IP del servidor
$IP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169\.' }).IPAddress | Select-Object -First 1

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "AdGuard Home instalado y en ejecucion." -ForegroundColor Green
Write-Host "Accede al panel web desde el navegador de tu PC en:" -ForegroundColor Yellow
Write-Host "http://$($IP):3000" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green
