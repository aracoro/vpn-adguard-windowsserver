Write-Host ">>> Configurando arquitectura NAT + Host-Only..." -ForegroundColor Cyan

# 1. Configurar Adaptador NAT (Salida a Internet)
$natNic = Get-NetAdapter | Where-Object { $_.Name -like "*Ethernet*" } | Select-Object -First 1
Set-NetIPInterface -InterfaceIndex $natNic.InterfaceIndex -Dhcp Enabled
Set-DnsClientServerAddress -InterfaceIndex $natNic.InterfaceIndex -ResetServerAddresses

# 2. Configurar Adaptador Host-Only (Comunicacion fija con la Laptop)
$hostNic = Get-NetAdapter | Where-Object { $_.InterfaceIndex -ne $natNic.InterfaceIndex } | Select-Object -First 1
if ($hostNic) {
    Remove-NetIPAddress -InterfaceIndex $hostNic.InterfaceIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
    New-NetIPAddress -InterfaceIndex $hostNic.InterfaceIndex -IPAddress 192.168.56.10 -PrefixLength 24
}

# 3. Desactivar Firewall de Windows
netsh advfirewall set allprofiles state off

# 4. Generar configuracion OpenVPN apuntando a la IP Host-Only
$vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if (Test-Path "C:\openvpn_config.zip") { Remove-Item "C:\openvpn_config.zip" -Force }
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnOriginal = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content -LiteralPath $ovpnOriginal.FullName) -replace '^remote .*', 'remote 192.168.56.10 1194' | Set-Content "C:\VPN-LAB.ovpn"

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "RED Y ARCHIVO LISTOS" -ForegroundColor Green
Write-Host "Descarga tu archivo en tu laptop entrando a:" -ForegroundColor Yellow
Write-Host "http://192.168.56.10:8080" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green

# 5. Servidor web local de descarga instantanea
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://192.168.56.10:8080/")
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
