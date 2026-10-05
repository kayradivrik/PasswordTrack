$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    VoidPass Release & Paketleme Araci    " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$sourceDir = Get-Location
$buildDir = "$sourceDir\build3"
$outputDir = "$sourceDir\VoidPass_Portable"
$exePath = "$buildDir\VoidPass.exe"
$zipPath = "$sourceDir\VoidPass_v1.0_Portable.zip"

Write-Host "`n[1/4] Mevcut derleme (build3) temizlenip guncelleniyor..." -ForegroundColor Yellow
if (Test-Path $outputDir) { Remove-Item -Recurse -Force $outputDir }
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }

# Derleme
Set-Location $buildDir
cmake --build . --config Release

# Çıktı Klasörünü Hazırla
Write-Host "`n[2/4] Çikti klasörü hazirlaniyor..." -ForegroundColor Yellow
Set-Location $sourceDir
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Copy-Item $exePath -Destination $outputDir

# windeployqt
Write-Host "`n[3/4] Qt DLL'leri ve QML bagimliliklari kopyalaniyor..." -ForegroundColor Yellow
Set-Location $outputDir
windeployqt --qmldir "$sourceDir\qml" --release --no-translations --compiler-runtime VoidPass.exe

# ZIP Arşivi
Write-Host "`n[4/4] Tasinabilir ZIP paketi olusturuluyor..." -ForegroundColor Yellow
Set-Location $sourceDir
Compress-Archive -Path "$outputDir\*" -DestinationPath $zipPath

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "    Basariyla Tamamlandi!                 " -ForegroundColor Green
Write-Host "    Paket: $zipPath                       " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
