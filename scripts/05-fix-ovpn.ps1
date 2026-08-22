Write-Host ">>> Localizando SoftEther VPN en el sistema..." -ForegroundColor Cyan

# 1. Obtener la ruta exacta del ejecutable
$vpncmd = $null

# Metodo A: Proceso activo
$proc = Get-Process -Name "*vpn*" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*vpnserver*" } | Select-Object -First 1
if ($proc -and $proc.Path) {
    $dir = Split-Path $proc.Path
    if (Test-Path (Join-Path $dir "vpncmd.exe")) { $vpncmd = Join-Path $dir "vpncmd.exe" }
}

# Metodo B: Registro de Windows
if (-not $vpncmd) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\sevpnserver"
    if (Test-Path $regPath) {
        $raw = (Get-ItemProperty $regPath).ImagePath
        if ($raw) {
            $cleaned = $raw.Trim('"')
            $dir = Split-Path $cleaned
            if (Test-Path (Join-Path $dir "vpncmd.exe")) { $vpncmd = Join-Path $dir "vpncmd.exe" }
        }
    }
}

# Metodo C: Rutas estandar
if (-not $vpncmd) {
    $candidates = @(
        "C:\Program Files\SoftEther VPN Server\vpncmd.exe",
        "C:\Program Files (x86)\SoftEther VPN Server\vpncmd.exe",
        "C:\SoftEther VPN Server\vpncmd.exe",
        "C:\SoftEther\vpncmd.exe",
        "C:\vpnserver\vpncmd.exe"
    )
    foreach ($cand in $candidates) {
        if (Test-Path $cand) { $vpncmd = $cand; break }
    }
}

Write-Host "Ruta detectada: $vpncmd" -ForegroundColor Yellow

if (-not $vpncmd) {
    Write-Error "No se pudo encontrar vpncmd.exe"
    return
}

# 2. Generar el zip de configuracion OpenVPN
if (Test-Path "C:\openvpn_config.zip") { Remove-Item "C:\openvpn_config.zip" -Force }
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

Start-Sleep -Seconds 2

# 3. Descomprimir y actualizar IP
if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnOriginal = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content $ovpnOriginal.FullName) -replace '^remote .*', 'remote 192.168.1.176 1194' | Set-Content "C:\VPN-LAB.ovpn"

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "CONFIGURACION GENERADA EN: C:\VPN-LAB.ovpn" -ForegroundColor Green
Write-Host "Abre en el navegador de tu laptop:" -ForegroundColor Yellow
Write-Host "http://192.168.1.176:8080" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green

# 4. Servidor web de descarga temporal
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

Write-Host "Archivo descargado correctamente en tu laptop." -ForegroundColor Green
