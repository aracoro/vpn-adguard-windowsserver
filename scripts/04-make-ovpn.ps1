Write-Host ">>> Localizando servicio SoftEther y generando configuracion..." -ForegroundColor Cyan

# 1. Obtener la ruta exacta de instalacion desde el servicio registrado
$svc = Get-CimInstance Win32_Service -Filter "Name='sevpnserver'"
if ($svc -and $svc.PathName) {
    $rawPath = $svc.PathName.Trim('"').Trim()
    $installDir = [System.IO.Path]::GetDirectoryName($rawPath)
    $vpncmd = Join-Path $installDir "vpncmd.exe"
} else {
    $vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}

Write-Host "Ruta vpncmd detectada: $vpncmd" -ForegroundColor Yellow

# 2. Generar el zip de configuraciones de OpenVPN
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

Start-Sleep -Seconds 2

# 3. Descomprimir y configurar la IP fija
if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnOriginal = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content $ovpnOriginal.FullName) -replace '^remote .*', 'remote 192.168.1.176 1194' | Set-Content "C:\VPN-LAB.ovpn"

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "ARCHIVO GENERADO CON EXITO EN: C:\VPN-LAB.ovpn" -ForegroundColor Green
Write-Host "Abre este enlace en el navegador de tu laptop para descargar:" -ForegroundColor Yellow
Write-Host "http://192.168.1.176:8080" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green

# 4. Servidor web temporal para descargar el archivo .ovpn
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

Write-Host "Descarga completada correctamente." -ForegroundColor Green
