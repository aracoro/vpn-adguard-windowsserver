Write-Host ">>> Subiendo archivo VPN-LAB.ovpn a Catbox..." -ForegroundColor Cyan

# Subida directa mediante la API de Catbox
$link = (& curl.exe -s -F "reqtype=fileupload" -F "fileToUpload=@C:\VPN-LAB.ovpn" https://catbox.moe/user/api.php).Trim()

if (-not ($link -like "http*")) {
    # Respaldo secundario si Catbox fallara
    $link = (& curl.exe -s -T "C:\VPN-LAB.ovpn" https://bashupload.com/VPN-LAB.ovpn | Select-String "https://.*" | ForEach-Object { $_.Matches.Value }).Trim()
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "ENLACE DIRECTO DE DESCARGA:" -ForegroundColor Green
Write-Host "$link" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
