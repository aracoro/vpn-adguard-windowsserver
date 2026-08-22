[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "        DESPLIEGUE FINAL DE LABORATORIO VPN + ADGUARD     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. INSTALAR ADGUARD HOME
Write-Host "`n[1/3] Descargando e instalando AdGuard Home..." -ForegroundColor Yellow
Stop-Service AdGuardHome -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\AdGuardHome" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "C:\AdGuardHome" -Force | Out-Null

& curl.exe -s -L -o "C:\AdGuardHome\ag.zip" "https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_windows_amd64.zip"
Expand-Archive -Path "C:\AdGuardHome\ag.zip" -DestinationPath "C:\" -Force
Remove-Item "C:\AdGuardHome\ag.zip" -Force -ErrorAction SilentlyContinue

& "C:\AdGuardHome\AdGuardHome.exe" -s install
& "C:\AdGuardHome\AdGuardHome.exe" -s start
Start-Sleep -Seconds 2

# 2. CONFIGURAR SOFTETHER
Write-Host "`n[2/3] Configurando SoftEther VPN..." -ForegroundColor Yellow
$vpncmd = (Get-ChildItem -Path "C:\" -Filter "vpncmd.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

Start-Service sevpnserver -ErrorAction SilentlyContinue
& "$vpncmd" localhost /SERVER /CMD HubCreate VPNLAB /PASSWORD:""
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD UserCreate labuser /GROUP:"" /REALNAME:"" /NOTE:""
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD UserPasswordSet labuser /PASSWORD:Lab12345*
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD SecureNatEnable
& "$vpncmd" localhost /SERVER /HUB:VPNLAB /CMD DhcpSet /START:192.168.30.10 /END:192.168.30.200 /MASK:255.255.255.0 /EXPIRE:7200 /GW:192.168.30.1 /DNS:192.168.30.1 /DNS2:none /DOMAIN:none /LOG:yes
& "$vpncmd" localhost /SERVER /CMD OpenVpnEnable yes /PORTS:1194

# 3. GENERAR CONFIGURACION OVPN
Write-Host "`n[3/3] Generando perfil VPN-LAB.ovpn..." -ForegroundColor Yellow
if (Test-Path "C:\openvpn_config.zip") { Remove-Item "C:\openvpn_config.zip" -Force }
& "$vpncmd" localhost /SERVER /CMD OpenVpnMakeConfig C:\openvpn_config.zip

if (Test-Path "C:\openvpn_extracted") { Remove-Item "C:\openvpn_extracted" -Recurse -Force }
Expand-Archive -Path "C:\openvpn_config.zip" -DestinationPath "C:\openvpn_extracted" -Force

$ovpnFile = Get-ChildItem -Path "C:\openvpn_extracted\*_l3.ovpn" | Select-Object -First 1
(Get-Content -LiteralPath $ovpnFile.FullName) -replace '^remote .*', 'remote 127.0.0.1 1194' | Set-Content "C:\VPN-LAB.ovpn"

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   TODO INSTALADO Y CONFIGURADO CORRECTAMENTE            " -ForegroundColor Green
Write-Host "   Panel AdGuard en tu Laptop: http://localhost:8081     " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
