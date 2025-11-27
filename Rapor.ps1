# Flutter Proje Dosyalarını Parçalara Bölerek TXT'ye Aktarma Betiği
# Türkçe karakter desteği ile
# Kullanım: .\export_project_to_txt.ps1 -MaxSizeKB 75

param(
    [int]$MaxSizeKB = 75  # Her parça maksimum KB
)

# Türkçe karakter desteği için encoding ayarla
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$outputEncoding = [System.Text.Encoding]::UTF8

$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$outputDir = "proje_export_$timestamp"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$script:currentPart = 1
$script:currentFile = ""
$script:fileList = @()

# Fonksiyon: Yeni parça dosyası oluştur
function New-PartFile {
    param([int]$PartNumber)
    
    $partFile = "$outputDir\parca_$("{0:D2}" -f $PartNumber).txt"
    $header = @"
================================================================================
FLUTTER PROJESİ - PARÇA $PartNumber
Tarih: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')
Proje: $(Split-Path -Leaf (Get-Location))
Encoding: UTF-8 (Türkçe karakter destekli)
================================================================================

"@
    [System.IO.File]::WriteAllText($partFile, $header, [System.Text.Encoding]::UTF8)
    Write-Host "📄 Yeni parça oluşturuldu: $partFile" -ForegroundColor Cyan
    return $partFile
}

# Fonksiyon: Dosya boyutunu KB cinsinden al
function Get-FileSizeKB {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        return [math]::Round((Get-Item $FilePath).Length / 1KB, 2)
    }
    return 0
}

# Fonksiyon: İçeriği ekle (boyut kontrolü ile)
function Add-ContentToPart {
    param(
        [string]$Content,
        [string]$Label = ""
    )
    
    # Mevcut dosya yoksa yeni oluştur
    if (-not $script:currentFile -or -not (Test-Path $script:currentFile)) {
        $script:currentFile = New-PartFile -PartNumber $script:currentPart
    }
    
    # Test: İçerik eklendiğinde boyut aşılacak mı?
    $tempFile = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tempFile, $Content, [System.Text.Encoding]::UTF8)
    $contentSize = (Get-Item $tempFile).Length / 1KB
    Remove-Item $tempFile
    
    $currentSize = Get-FileSizeKB -FilePath $script:currentFile
    
    # Boyut aşılacaksa yeni parça aç
    if (($currentSize + $contentSize) -gt $MaxSizeKB -and $currentSize -gt 5) {
        $script:currentPart++
        $script:currentFile = New-PartFile -PartNumber $script:currentPart
        Write-Host "  ↳ Boyut limiti aşıldı, yeni parça açıldı" -ForegroundColor Yellow
    }
    
    # İçeriği ekle (UTF-8 ile)
    [System.IO.File]::AppendAllText($script:currentFile, $Content, [System.Text.Encoding]::UTF8)
    
    if ($Label) {
        Write-Host "  ✓ $Label" -ForegroundColor Green
    }
}

# Fonksiyon: Dosya içeriğini formatla ve ekle
function Add-FileContent {
    param(
        [string]$FilePath,
        [string]$Description = ""
    )
    
    if (Test-Path $FilePath) {
        $relativePath = Resolve-Path -Path $FilePath -Relative
        $separator = "`n" + ("=" * 80) + "`n"
        
        $header = @"
$separator
DOSYA: $relativePath
$Description
$separator

"@
        
        try {
            # Dosyayı UTF-8 olarak oku
            $fileContent = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
            $fullContent = $header + $fileContent + "`n`n"
            
            Add-ContentToPart -Content $fullContent -Label $relativePath
            $script:fileList += $relativePath
            
        } catch {
            $errorContent = $header + "[HATA: Dosya okunamadı - $_]`n`n"
            Add-ContentToPart -Content $errorContent -Label "$relativePath (HATA)"
        }
    } else {
        Write-Host "  ✗ Bulunamadı: $FilePath" -ForegroundColor Yellow
    }
}

Write-Host "`n🔍 Proje dosyaları taranıyor...`n" -ForegroundColor Cyan
Write-Host "📊 Maksimum parça boyutu: $MaxSizeKB KB`n" -ForegroundColor Cyan

# Başlangıç dosyası oluştur
$script:currentFile = New-PartFile -PartNumber 1

# 1. Config dosyaları
Write-Host "`n📋 Config dosyaları ekleniyor..." -ForegroundColor Cyan
Add-ContentToPart -Content "`n### 1. YAPILANDIRMA DOSYALARI ###`n`n"

$configFiles = @(
    "pubspec.yaml",
    "pubspec.lock",
    "analysis_options.yaml",
    "README.md"
)

foreach ($file in $configFiles) {
    Add-FileContent -FilePath $file
}

# 2. Dart dosyaları
Write-Host "`n💙 Dart dosyaları ekleniyor..." -ForegroundColor Cyan
Add-ContentToPart -Content "`n### 2. DART KAYNAK DOSYALARI ###`n`n"

$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse -ErrorAction SilentlyContinue
$dartCount = 0

foreach ($file in $dartFiles) {
    Add-FileContent -FilePath $file.FullName
    $dartCount++
}

# 3. Platform config dosyaları
Write-Host "`n🔧 Platform dosyaları ekleniyor..." -ForegroundColor Cyan
Add-ContentToPart -Content "`n### 3. PLATFORM YAPILANDIRMA ###`n`n"

$platformConfigs = @(
    @{Path="android\app\build.gradle"; Desc="Android Gradle Build"},
    @{Path="android\build.gradle"; Desc="Android Root Gradle"},
    @{Path="android\settings.gradle"; Desc="Android Settings"},
    @{Path="android\app\src\main\AndroidManifest.xml"; Desc="Android Manifest"},
    @{Path="ios\Podfile"; Desc="iOS Podfile"},
    @{Path="ios\Runner\Info.plist"; Desc="iOS Info.plist"},
    @{Path="windows\CMakeLists.txt"; Desc="Windows CMake"},
    @{Path="web\index.html"; Desc="Web Index"},
    @{Path="web\manifest.json"; Desc="Web Manifest"}
)

foreach ($config in $platformConfigs) {
    Add-FileContent -FilePath $config.Path -Description $config.Desc
}

# 4. Firebase config
Write-Host "`n🔥 Firebase dosyaları ekleniyor..." -ForegroundColor Cyan
Add-ContentToPart -Content "`n### 4. FIREBASE YAPILANDIRMA ###`n`n"

$firebaseConfigs = @(
    "android\app\google-services.json",
    "ios\Runner\GoogleService-Info.plist",
    "lib\firebase_options.dart"
)

foreach ($file in $firebaseConfigs) {
    Add-FileContent -FilePath $file
}

# 5. Proje yapısı
Write-Host "`n📁 Proje yapısı ekleniyor..." -ForegroundColor Cyan
Add-ContentToPart -Content "`n### 5. PROJE YAPISI ###`n`n"

$treeOutput = tree lib /F /A 2>$null | Out-String
if ($treeOutput) {
    Add-ContentToPart -Content $treeOutput
}

# 6. Bağımlılıklar
Write-Host "`n📦 Bağımlılıklar listeleniyor..." -ForegroundColor Cyan
Add-ContentToPart -Content "`n### 6. BAĞIMLILIKLAR ###`n`n"

try {
    $deps = flutter pub deps --no-dev 2>$null | Out-String
    Add-ContentToPart -Content $deps
} catch {
    Add-ContentToPart -Content "Bağımlılıklar listelenemedi.`n"
}

# Özet dosyası oluştur
$summaryFile = "$outputDir\00_OKUBENI.txt"
$totalParts = $script:currentPart
$totalFiles = $script:fileList.Count

$summary = @"
================================================================================
                    FLUTTER PROJESİ DÖKÜMÜ - ÖZET
================================================================================

📅 Oluşturulma: $(Get-Date -Format 'dd.MM.yyyy HH:mm:ss')
📂 Proje: $(Split-Path -Leaf (Get-Location))
🔤 Encoding: UTF-8 (Türkçe karakter destekli)

📊 İSTATİSTİKLER:
   • Toplam Parça Sayısı: $totalParts
   • Toplam Dosya: $totalFiles
   • Dart Dosyası: $dartCount
   • Maksimum Parça Boyutu: $MaxSizeKB KB

📄 PARÇA DOSYALARI:
"@

for ($i = 1; $i -le $totalParts; $i++) {
    $partFile = "parca_$("{0:D2}" -f $i).txt"
    $partPath = "$outputDir\$partFile"
    $partSize = Get-FileSizeKB -FilePath $partPath
    $summary += "`n   $i. $partFile ($partSize KB)"
}

$summary += @"


📋 DAHİL EDİLEN DOSYALAR:
"@

foreach ($file in $script:fileList) {
    $summary += "`n   • $file"
}

$summary += @"


💡 KULLANIM:
   1. Tüm parça dosyalarını sırayla Claude'a yükleyin
   2. Bu özet dosyasını da yüklerseniz daha iyi olur
   3. Her parça UTF-8 encoding ile kaydedilmiştir

================================================================================
"@

[System.IO.File]::WriteAllText($summaryFile, $summary, [System.Text.Encoding]::UTF8)

# Konsol özeti
Write-Host "`n`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Green
Write-Host "                         TAMAMLANDI!" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green
Write-Host "`n📊 İstatistikler:" -ForegroundColor Cyan
Write-Host "   • Toplam Parça: $totalParts" -ForegroundColor White
Write-Host "   • Toplam Dosya: $totalFiles" -ForegroundColor White
Write-Host "   • Dart Dosyası: $dartCount" -ForegroundColor White
Write-Host "`n📁 Çıktı Klasörü: $outputDir" -ForegroundColor Cyan
Write-Host "`n📄 Oluşturulan Dosyalar:" -ForegroundColor Cyan

Get-ChildItem -Path $outputDir | ForEach-Object {
    $size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "   • $($_.Name) ($size KB)" -ForegroundColor White
}

Write-Host "`n💡 Tüm dosyaları Claude'a yükleyebilirsiniz!" -ForegroundColor Yellow
Write-Host ("=" * 80) -ForegroundColor Green
Write-Host ""