Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         DIAGNOSTICO COMPLETO DEL LABORATORIO VPN         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. SERVICIOS
Write-Host "`n[1. ESTADO DE SERVICIOS]" -ForegroundColor Yellow
$seSvc = Get-Service -Name "sevpnserver" -ErrorAction SilentlyContinue
$agSvc = Get-Service -Name "AdGuardHome" -ErrorAction SilentlyContinue

if ($seSvc -and $seSvc.Status -eq "Running") {
    Write-Host "  [OK] SoftEther VPN Server: EN EJECUCION" -ForegroundColor Green
} else {
    Write-Host "  [FALLO] SoftEther VPN Server: DETENIDO O NO INSTALADO" -ForegroundColor Red
}

if ($agSvc -and $agSvc.Status -eq "Running") {
    Write-Host "  [OK] AdGuard Home: EN EJECUCION" -ForegroundColor Green
} else {
    Write-Host "  [FALLO] AdGuard Home: DETENIDO O NO INSTALADO" -ForegroundColor Red
}

# 2. ADAPTADORES DE RED E IPS
Write-Host "`n[2. INTERFACES DE RED E IPS CONFIGURADAS]" -ForegroundColor Yellow
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" } | ForEach-Object {
    Write-Host "  Interfaz: $($_.InterfaceAlias) | IP: $($_.IPAddress)/$($_.PrefixLength)" -ForegroundColor Cyan
}

# 3. PUERTOS EN ESCUCHA
Write-Host "`n[3. VERIFICACION DE PUERTOS CLAVE]" -ForegroundColor Yellow

# TCP 80 (AdGuard Web)
$p80 = Get-NetTCPConnection -LocalPort 80 -State Listen -ErrorAction SilentlyContinue
if ($p80) { Write-Host "  [OK] TCP 80 (AdGuard Web): ESCUCHANDO" -ForegroundColor Green }
else { Write-Host "  [FALLO] TCP 80 (AdGuard Web): NO ESTA ESCUCHANDO" -ForegroundColor Red }

# UDP 53 (AdGuard DNS)
$p53 = Get-NetUDPEndpoint -LocalPort 53 -ErrorAction SilentlyContinue
if ($p53) { Write-Host "  [OK] UDP 53 (DNS AdGuard): ESCUCHANDO" -ForegroundColor Green }
else { Write-Host "  [FALLO] UDP 53 (DNS AdGuard): NO ESTA ESCUCHANDO" -ForegroundColor Red }

# UDP 1194 (OpenVPN)
$p1194 = Get-NetUDPEndpoint -LocalPort 1194 -ErrorAction SilentlyContinue
if ($p1194) { Write-Host "  [OK] UDP 1194 (OpenVPN): ESCUCHANDO" -ForegroundColor Green }
else { Write-Host "  [FALLO] UDP 1194 (OpenVPN): NO ESTA ESCUCHANDO" -ForegroundColor Red }

# 4. FIREWALL DE WINDOWS
Write-Host "`n[4. ESTADO DEL FIREWALL]" -ForegroundColor Yellow
$fw = Get-NetFirewallProfile
$fwActive = $fw | Where-Object { $_.Enabled -eq $true }
if ($fwActive) {
    Write-Host "  [AVISO] Firewall activo en perfiles: $($fwActive.Name -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host "  [OK] Firewall completamente DESACTIVADO" -ForegroundColor Green
}

# 5. CONFIGURACION DE SOFTETHER (OpenVPN & SecureNAT)
Write-Host "`n[5. ESTADO DE OPENVPN EN SOFTETHER]" -ForegroundColor Yellow
$vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

if ($vpncmd) {
    $ovpnStatus = & "$vpncmd" localhost /SERVER /CMD OpenVpnGet
    $enabledLine = $ovpnStatus | Select-String "Enable OpenVPN"
    Write-Host "  $enabledLine" -ForegroundColor Cyan
} else {
    Write-Host "  [FALLO] No se encontro vpncmd.exe" -ForegroundColor Red
}

# 6. ARCHIVO OVPN
Write-Host "`n[6. ARCHIVO DE CONFIGURACION OVPN]" -ForegroundColor Yellow
if (Test-Path "C:\VPN-LAB.ovpn") {
    $size = (Get-Item "C:\VPN-LAB.ovpn").Length
    Write-Host "  [OK] C:\VPN-LAB.ovpn existe ($size bytes)" -ForegroundColor Green
    $remLine = Get-Content "C:\VPN-LAB.ovpn" | Select-String "^remote " | Select-Object -First 1
    Write-Host "  Linea de conexion: $remLine" -ForegroundColor Cyan
} else {
    Write-Host "  [FALLO] No existe C:\VPN-LAB.ovpn" -ForegroundColor Red
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
