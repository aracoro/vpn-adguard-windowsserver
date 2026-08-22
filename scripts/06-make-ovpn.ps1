Write-Host ">>> Localizando vpncmd.exe de SoftEther..." -ForegroundColor Cyan

# 1. Busqueda limpia y directa
$vpncmd = $null
$rutas = @(
    "C:\Program Files\SoftEther VPN Server\vpncmd.exe",
    "C:\Program Files (x86)\SoftEther VPN Server\vpncmd.exe",
    "C:\SoftEther VPN Server\vpncmd.exe",
    "C:\SoftEther\vpncmd.exe"
)

foreach ($r in $rutas) {
    if (Test-Path -LiteralPath $r) {
        $vpncmd = $r
        break
    }
}

if (-not $vpncmd) {
    $encontrado = Get-ChildItem -Path "C:\Program Files" -Filter "vpncmd.exe" -Recurse -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($encontrado) { $vpncmd = $encontrado.FullName }
}

if (-not $vpncmd) {
    $encontrado = Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($encontrado) { $vpncmd = $encontrado.FullName }
}

Write-Host "vpncmd ubicado en: $vpncmd" -ForegroundColor Green

if (-not $vpncmd) {
    Write-Error "No se encontro vpncmd.exe en el sistema."
    return
}

# 2. Generar el zip de configuraciones de OpenVPN
if (Test-Path "C:\openvpn_config.zip") { Remove-Item "C:\openvpn_config.zip" -Force }

& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip
if (-not (Test-Path "C:\openvpn_config.zip")) {
    & "$vpncmd" localhost /SERVER /PASSWORD:Lab12345* /CMD OpenVpnMakeConfig C:\openvpn_config.zip
}

Start-Sleep -Seconds 2

# 3. Descomprimir el archivo ZIP
if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

# 4. Extraer el perfil y configurar la IP fija
$ovpnFile = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
if (-not $ovpnFile) {
    $ovpnFile = Get-ChildItem -Path "C:\openvpn_extracted\*.ovpn" | Select-Object -First 1
}

(Get-Content -LiteralPath $ovpnFile.FullName) -replace '^remote .*', 'remote 192.168.1.176 1194' | Set-Content "C:\VPN-LAB.ovpn"

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "ARCHIVO OVPN GENERADO EN: C:\VPN-LAB.ovpn" -ForegroundColor Green
Write-Host "Descargalo abriendo este enlace en tu laptop:" -ForegroundColor Yellow
Write-Host "http://192.168.1.176:8080" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green

# 5. Servidor web temporal para descargar el archivo
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

Write-Host "Descarga finalizada con exito." -ForegroundColor Green
