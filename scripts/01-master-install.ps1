Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   INSTALACION MAESTRA: ADGUARD HOME + SOFTETHER VPN      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# ----------------------------------------------------
# 1. INSTALACION Y CONFIGURACION DE ADGUARD HOME
# ----------------------------------------------------
Write-Host "`n[1/3] Configurando AdGuard Home..." -ForegroundColor Yellow
$agDir = "C:\AdGuardHome"
if (-not (Test-Path $agDir)) {
    New-Item -ItemType Directory -Path $agDir | Out-Null
    Invoke-WebRequest -Uri "https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_windows_amd64.zip" -OutFile "$agDir\ag.zip"
    Expand-Archive -Path "$agDir\ag.zip" -DestinationPath "C:\" -Force
    Remove-Item "$agDir\ag.zip" -Force
}

# Iniciar / Registrar servicio AdGuard
& "$agDir\AdGuardHome.exe" -s install
& "$agDir\AdGuardHome.exe" -s start
Start-Sleep -Seconds 3

# ----------------------------------------------------
# 2. CONFIGURACION DE SOFTETHER VPN
# ----------------------------------------------------
Write-Host "`n[2/3] Configurando SoftEther VPN & SecureNAT..." -ForegroundColor Yellow
$vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

# Iniciar servicio SoftEther si no esta corriendo
Start-Service sevpnserver -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Configurar Hub, Usuario y SecureNAT apuntando el DNS al AdGuard (192.168.30.1)
& "$vpncmd" localhost /SERVER /CMD HubCreate VPNLAB /PASSWORD:""
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD UserCreate labuser /GROUP:"" /REALNAME:"" /NOTE:""
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD UserPasswordSet labuser /PASSWORD:Lab12345*

# Habilitar SecureNAT con DNS hacia la IP virtual interna
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD SecureNatEnable
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD DhcpSet /START:192.168.30.10 /END:192.168.30.200 /MASK:255.255.255.0 /EXPIRE:7200 /GW:192.168.30.1 /DNS:192.168.30.1 /DNS2:none /DOMAIN:none /LOG:yes

# Habilitar protocolo OpenVPN en UDP 1194
& "$vpncmd" localhost /SERVER /CMD OpenVpnEnable yes /PORTS:1194

# ----------------------------------------------------
# 3. EXPORTAR PERFIL OVPN Y PUBLICAR ENLACE
# ----------------------------------------------------
Write-Host "`n[3/3] Generando perfil OpenVPN para tu laptop..." -ForegroundColor Yellow
if (Test-Path "C:\openvpn_config.zip") { Remove-Item "C:\openvpn_config.zip" -Force }
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnFile = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content -LiteralPath $ovpnFile.FullName) -replace '^remote .*', 'remote 127.0.0.1 1194' | Set-Content "C:\VPN-LAB.ovpn"

# Subir a dpaste de forma segura
$content = Get-Content -Path "C:\VPN-LAB.ovpn" -Raw
$body = @{ content = $content; syntax = "text"; expiry_days = 1 }
$url = (Invoke-RestMethod -Uri "https://dpaste.org/api/" -Method Post -Body $body).Trim() + "/raw"

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "       LABORATORIO DESPLEGADO CON EXITO TOTAL             " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "1. Panel AdGuard en tu Laptop:   http://localhost:8081" -ForegroundColor Yellow
Write-Host "2. Descarga tu archivo OVPN en:  $url" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green
