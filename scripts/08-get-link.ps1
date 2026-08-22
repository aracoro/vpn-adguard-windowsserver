Write-Host "Subiendo VPN-LAB.ovpn con curl nativo de Windows..." -ForegroundColor Cyan

# curl.exe nativo de Windows compatible con PowerShell 5.1
$link = (& curl.exe -s -F "file=@C:\VPN-LAB.ovpn" https://0x0.st).Trim()

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "DESCARGA TU ARCHIVO DIRECTAMENTE EN ESTE ENLACE:" -ForegroundColor Green
Write-Host "$link" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
