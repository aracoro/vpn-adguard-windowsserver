Write-Host "Subiendo VPN-LAB.ovpn para descarga directa..." -ForegroundColor Cyan

$link = (Invoke-RestMethod -Uri "https://0x0.st" -Method Post -Form @{file=Get-Item "C:\VPN-LAB.ovpn"}).Trim()

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "DESCARGA TU ARCHIVO DIRECTAMENTE EN ESTE ENLACE:" -ForegroundColor Green
Write-Host "$link" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
