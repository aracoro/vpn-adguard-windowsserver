[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. Asegurar que vpncmd extraiga el archivo .ovpn
$vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnFile = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content -LiteralPath $ovpnFile.FullName) -replace '^remote .*', 'remote 127.0.0.1 1194' | Set-Content "C:\VPN-LAB.ovpn"

# 2. Subir a transfer.sh para generar enlace directo
$link = (& curl.exe -s --upload-file "C:\VPN-LAB.ovpn" https://transfer.sh/VPN-LAB.ovpn).Trim()

Clear-Host
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "ARCHIVO LISTO PARA DESCARGAR EN TU LAPTOP" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "`nAbre este enlace en Chrome o Edge en tu laptop:`n" -ForegroundColor White
Write-Host "$link" -ForegroundColor Yellow
Write-Host "`n==========================================================" -ForegroundColor Green
