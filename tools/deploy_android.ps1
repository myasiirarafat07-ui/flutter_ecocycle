<#
.SYNOPSIS
  Build + install APK EcoCycle ke HP yang tercolok, otomatis mengarah ke IP laptop saat ini.

.DESCRIPTION
  Dipakai untuk demo Jalur A (hotspot HP / Wi-Fi LAN). Skrip:
    1. Mendeteksi IP laptop (default: adapter Wi-Fi) — atau pakai -Ip <alamat>.
    2. Build APK release dengan API_BASE_URL=http://<IP>:3000.
    3. Install ke HP yang terhubung via ADB (USB debugging aktif).

.EXAMPLE
  .\tools\deploy_android.ps1
  # Auto-deteksi IP Wi-Fi, build, install.

.EXAMPLE
  .\tools\deploy_android.ps1 -Ip 10.192.184.212
  # Paksa pakai IP tertentu.

.EXAMPLE
  .\tools\deploy_android.ps1 -Port 3000 -Interface 'Wi-Fi'
#>
param(
  [string]$Ip,
  [int]$Port = 3000,
  [string]$Interface = 'Wi-Fi'
)

$ErrorActionPreference = 'Stop'
# Selalu jalan relatif terhadap root proyek (parent dari folder tools).
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

# 1) Tentukan IP
if (-not $Ip) {
  $addr = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
      $_.InterfaceAlias -eq $Interface -and
      $_.IPAddress -notlike '169.254.*' -and
      $_.IPAddress -ne '127.0.0.1'
    } | Select-Object -First 1
  if ($addr) { $Ip = $addr.IPAddress }
}
if (-not $Ip) {
  Write-Host "[X] IP tidak terdeteksi di adapter '$Interface'." -ForegroundColor Red
  Write-Host "    Pastikan laptop terhubung ke hotspot HP, atau jalankan dengan -Ip <alamat>." -ForegroundColor Yellow
  exit 1
}

$base = "http://${Ip}:${Port}"
Write-Host "==> Target API_BASE_URL = $base" -ForegroundColor Cyan

# 2) Build APK release
Write-Host "==> Build APK release..." -ForegroundColor Cyan
flutter build apk --release --dart-define=API_BASE_URL=$base
if ($LASTEXITCODE -ne 0) {
  Write-Host "[X] Build gagal." -ForegroundColor Red
  exit 1
}

# 3) Install ke HP via ADB
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
  $cmd = Get-Command adb -ErrorAction SilentlyContinue
  if ($cmd) { $adb = $cmd.Source }
}
if (-not (Test-Path $adb)) {
  Write-Host "[X] adb tidak ditemukan. Install Android SDK platform-tools." -ForegroundColor Red
  exit 1
}

$apk = Join-Path $root 'build\app\outputs\flutter-apk\app-release.apk'
$devices = (& $adb devices) | Select-String -Pattern "\tdevice$"
if (-not $devices) {
  Write-Host "[!] Tidak ada HP terdeteksi ADB. APK sudah dibuat di:" -ForegroundColor Yellow
  Write-Host "    $apk" -ForegroundColor Yellow
  Write-Host "    Aktifkan USB debugging lalu jalankan ulang, atau install manual." -ForegroundColor Yellow
  exit 1
}

Write-Host "==> Install ke HP..." -ForegroundColor Cyan
& $adb install -r $apk
Write-Host "==> Selesai. Buka aplikasi EcoCycle di HP." -ForegroundColor Green
Write-Host "    (Pastikan backend jalan: cd backend; npm run dev)" -ForegroundColor Green
