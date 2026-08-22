Write-Host ">>> Obteniendo enlace de descarga del archivo OVPN..." -ForegroundColor Cyan

$content = Get-Content -Path "C:\VPN-LAB.ovpn" -Raw

$body = @{
    content = $content
    syntax = "text"
    expiry_days = 1
}

$url = Invoke-RestMethod -Uri "https://dpaste.org/api/" -Method Post -Body $body
$downloadLink = $url.Trim() + "/raw"

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "DESCARGA TU ARCHIVO AQUI DIRECTAMENTE:" -ForegroundColor Green
Write-Host "$downloadLink" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
