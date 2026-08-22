Write-Host "Generando configuracion OpenVPN desde SoftEther..." -ForegroundColor Cyan

# 1. Ubicar vpncmd
$sePath = "C:\Program Files\SoftEther VPN Server"
if (-not (Test-Path $sePath)) { $sePath = "C:\SoftEther" }

# 2. Generar el zip de configuraciones de SoftEther
& "$sePath\vpncmd.exe" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

# 3. Extraer el perfil L3
Expand-Archive -Path C:\openvpn_config.zip -DestinationPath C:\openvpn_extracted -Force
$ovpnFile = Get-ChildItem -Path C:\openvpn_extracted\*_l3.ovpn | Select-Object -First 1

# 4. Inyectar la IP estatica del servidor
(Get-Content $ovpnFile.FullName) -replace '^remote .*', 'remote 192.168.1.176 1194' | Set-Content C:\VPN-LAB.ovpn

# 5. Levantar servidor temporal de descarga en el puerto 8080
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Esperando descarga en tu navegador..." -ForegroundColor Yellow
Write-Host "Entra en tu laptop a: http://192.168.1.176:8080" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:8080/")
$listener.Start()

$context = $listener.GetContext()
$content = [System.IO.File]::ReadAllBytes("C:\VPN-LAB.ovpn")
$context.Response.ContentType = "application/x-openvpn-profile"
$context.Response.AddHeader("Content-Disposition", "attachment; filename=VPN-LAB.ovpn")
$context.Response.OutputStream.Write($content, 0, $content.Length)
$context.Response.Close()
$listener.Stop()

Write-Host "Archivo VPN-LAB.ovpn descargado correctamente en tu laptop." -ForegroundColor Green
