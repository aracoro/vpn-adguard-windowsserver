# Forzar soporte para TLS 1.2 y TLS 1.3 en PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   INSTALACION MAESTRA: ADGUARD HOME + SOFTETHER VPN      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# ----------------------------------------------------
# 1. INSTALACION LIMPIA DE ADGUARD HOME
# ----------------------------------------------------
Write-Host "`n[1/3] Descargando e instalando AdGuard Home..." -ForegroundColor Yellow

# Detener si habia quedado algun residuo
Stop-Service AdGuardHome -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\AdGuardHome" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "C:\AdGuardHome" -Force | Out-Null

# Descarga robusta con curl nativo
& curl.exe -L -o "C:\AdGuardHome\ag.zip" "https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_windows_amd64.zip"

# Descomprimir e instalar servicio
Expand-Archive -Path "C:\AdGuardHome\ag.zip" -DestinationPath "C:\" -Force
Remove-Item "C:\AdGuardHome\ag.zip" -Force -ErrorAction SilentlyContinue

& "C:\AdGuardHome\AdGuardHome.exe" -s install
& "C:\AdGuardHome\AdGuardHome.exe" -s start
Start-Sleep -Seconds 3

# ----------------------------------------------------
# 2. CONFIGURACION DE SOFTETHER VPN & SECURENAT
# ----------------------------------------------------
Write-Host "`n[2/3] Configurando SoftEther VPN..." -ForegroundColor Yellow
$vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

Start-Service sevpnserver -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Hub, Usuario y SecureNAT
& "$vpncmd" localhost /SERVER /CMD HubCreate VPNLAB /PASSWORD:""
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD UserCreate labuser /GROUP:"" /REALNAME:"" /NOTE:""
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD UserPasswordSet labuser /PASSWORD:Lab12345*

# Habilitar SecureNAT con DNS hacia la IP virtual interna
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD SecureNatEnable
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD DhcpSet /START:192.168.30.10 /END:192.168.30.200 /MASK:255.255.255.0 /EXPIRE:7200 /GW:192.168.30.1 /DNS:192.168.30.1 /DNS2:none /DOMAIN:none /LOG:yes

# Habilitar OpenVPN en puerto UDP 1194
& "$vpncmd" localhost /SERVER /CMD OpenVpnEnable yes /PORTS:1194

# ----------------------------------------------------
# 3. GENERAR Y SUBIR ARCHIVO OVPN
# ----------------------------------------------------
Write-Host "`n[3/3] Generando perfil OpenVPN para tu Laptop..." -ForegroundColor Yellow

if (Test-Path "C:\openvpn_config.zip") { Remove-Item "C:\openvpn_config.zip" -Force }
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnFile = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content -LiteralPath $ovpnFile.FullName) -replace '^remote .*', 'remote 127.0.0.1 1194' | Set-Content "C:\VPN-LAB.ovpn"

# Subida a paste.rs y dpaste.com
$link1 = (& curl.exe -s --data-binary "@C:\VPN-LAB.ovpn" https://paste.rs).Trim()
$link2 = (& curl.exe -s -F "content=<C:\VPN-LAB.ovpn" https://dpaste.com/api/).Trim()

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "       LABORATORIO DESPLEGADO Y OPERATIVO AL 100%         " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "1. Panel AdGuard en tu Laptop: http://localhost:8081" -ForegroundColor Yellow

if ($link1 -like "http*") {
    Write-Host "2. Descarga tu OVPN en:        $link1" -ForegroundColor Cyan
} elseif ($link2 -like "http*") {
    Write-Host "2. Descarga tu OVPN en:        $link2.txt" -ForegroundColor Cyan
}
Write-Host "==========================================================" -ForegroundColor Green
