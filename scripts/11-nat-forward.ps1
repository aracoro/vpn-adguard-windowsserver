Write-Host ">>> Preparando entrega local y configuracion VPN..." -ForegroundColor Cyan

# 1. Asegurar reglas de firewall interno
netsh advfirewall set allprofiles state off

# 2. Localizar vpncmd
$vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

# 3. Regenerar el archivo OVPN apuntando a localhost (127.0.0.1)
if (Test-Path "C:\openvpn_config.zip") { Remove-Item "C:\openvpn_config.zip" -Force }
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnOriginal = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content -LiteralPath $ovpnOriginal.FullName) -replace '^remote .*', 'remote 127.0.0.1 1194' | Set-Content "C:\VPN-LAB.ovpn"

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "LISTO PARA DESCARGAR DESDE LOCALHOST" -ForegroundColor Green
Write-Host "Abre en tu navegador: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Panel AdGuard en:     http://localhost:8081" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green

# 4. Servidor de descarga escuchando en todos los enlaces
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:8080/")
$listener.Start()

$context = $listener.GetContext()
$response = $context.Response
$content = [System.IO.File]::ReadAllBytes("C:\VPN-LAB.ovpn")

$response.ContentType = "application/x-openvpn-profile"
$response.AddHeader("Content-Disposition", "attachment; filename=VPN-LAB.ovpn")
$response.ContentLength64 = $content.Length
$response.OutputStream.Write($content, 0, $content.Length)
$response.Close()
$listener.Stop()

Write-Host "Descarga completada en tu laptop." -ForegroundColor Green
