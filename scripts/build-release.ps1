# Invictus Trader Pro - Build Script
# PowerShell version with enhanced features

param(
    [switch]$SkipTests,
    [switch]$Debug,
    [string]$Version = ""
)

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor White
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Text)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Text" -ForegroundColor Green
}

function Write-Error {
    param([string]$Text)
    Write-Host "[ERROR] $Text" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Text)
    Write-Host "[WARNING] $Text" -ForegroundColor Yellow
}

# Main script
try {
    Write-Header "INVICTUS TRADER PRO - BUILD SCRIPT"

    # Check prerequisites
    Write-Step "Checking prerequisites..."
    
    if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Error "Flutter is not installed or not in PATH"
        exit 1
    }
    
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is not installed or not in PATH"
        exit 1
    }

    # Get version info
    if ([string]::IsNullOrEmpty($Version)) {
        $pubspecContent = Get-Content "pubspec.yaml"
        $versionLine = $pubspecContent | Where-Object { $_ -match "^version:" }
        if ($versionLine) {
            $Version = ($versionLine -split ":")[1].Trim()
        } else {
            $Version = "1.0.0+1"
        }
    }
    
    Write-Host "Building version: $Version" -ForegroundColor Cyan

    # Step 1: Clean
    Write-Step "Cleaning previous builds..."
    flutter clean
    if ($LASTEXITCODE -ne 0) { throw "Flutter clean failed" }

    # Step 2: Dependencies
    Write-Step "Getting dependencies..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "Flutter pub get failed" }

    # Step 3: Analysis (optional)
    if (!$SkipTests) {
        Write-Step "Running analyzer..."
        flutter analyze
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Flutter analyzer found issues. Continue? (Y/N)"
            $continue = Read-Host
            if ($continue.ToUpper() -ne "Y") {
                exit 1
            }
        }
    }

    # Step 4: Build Android
    Write-Step "Building Android APK..."
    $buildType = if ($Debug) { "--debug" } else { "--release" }
    flutter build apk $buildType --target-platform android-arm64
    if ($LASTEXITCODE -ne 0) { throw "Android build failed" }

    # Step 5: Enable and Build Windows
    Write-Step "Building Windows EXE..."
    flutter config --enable-windows-desktop
    flutter build windows $buildType
    if ($LASTEXITCODE -ne 0) { throw "Windows build failed" }

    # Step 6: Package releases
    Write-Step "Creating release packages..."
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $releaseDir = "releases\v$Version-$timestamp"
    
    if (!(Test-Path "releases")) { New-Item -ItemType Directory -Path "releases" }
    if (!(Test-Path $releaseDir)) { New-Item -ItemType Directory -Path $releaseDir }

    # Copy Android APK
    $buildFolder = if ($Debug) { "debug" } else { "release" }
    $apkSource = "build\app\outputs\flutter-apk\app-$buildFolder.apk"
    $apkDest = "$releaseDir\InvictusTraderPro-Android-v$Version.apk"
    
    if (Test-Path $apkSource) {
        Copy-Item $apkSource $apkDest
        Write-Host "✓ Android APK: $apkDest" -ForegroundColor Green
    } else {
        Write-Warning "Android APK not found at $apkSource"
    }

    # Package Windows EXE
    $winSource = "build\windows\x64\runner\Release\*"
    $winDest = "$releaseDir\InvictusTraderPro-Windows-v$Version.zip"
    
    if (Test-Path "build\windows\x64\runner\Release") {
        Compress-Archive -Path $winSource -DestinationPath $winDest -Force
        Write-Host "✓ Windows EXE: $winDest" -ForegroundColor Green
    } else {
        Write-Warning "Windows build not found"
    }

    # Create release info
    $releaseInfo = @"
# Invictus Trader Pro v$Version

## Release Information
- **Build Date**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **Build Type**: $(if ($Debug) { 'Debug' } else { 'Release' })
- **Flutter Version**: $(flutter --version | Select-String "Flutter" | Out-String).Trim()

## Compatibility
### Android APK
- **Minimum Android**: 8.0 (API 26)
- **Target Android**: 14 (API 34)
- **Architecture**: ARM64
- **Size**: $((Get-Item $apkDest).Length / 1MB | ForEach-Object { "{0:N1} MB" -f $_ })

### Windows EXE
- **Minimum Windows**: 10 (64-bit)
- **Architecture**: x64
- **Size**: $((Get-Item $winDest).Length / 1MB | ForEach-Object { "{0:N1} MB" -f $_ })

## Features
- ✅ Subscription-based monetization (\$5/month, \$100/year)
- ✅ Real-time Binance API integration
- ✅ Advanced trading features
- ✅ AI-powered market analysis
- ✅ No ads - Premium experience only

## Installation
### Android
1. Enable "Unknown sources" in Android settings
2. Install the APK file
3. Grant required permissions

### Windows
1. Extract the ZIP file
2. Run InvictusTraderPro.exe
3. Windows Defender may show a warning (normal for unsigned apps)
"@

    $releaseInfo | Out-File -FilePath "$releaseDir\README.md" -Encoding UTF8

    Write-Header "BUILD COMPLETED SUCCESSFULLY!"
    Write-Host "📁 Release folder: $releaseDir" -ForegroundColor Cyan
    Write-Host "📱 Android APK: $(if (Test-Path $apkDest) { '✓' } else { '✗' })" -ForegroundColor $(if (Test-Path $apkDest) { 'Green' } else { 'Red' })
    Write-Host "🖥️  Windows EXE: $(if (Test-Path $winDest) { '✓' } else { '✗' })" -ForegroundColor $(if (Test-Path $winDest) { 'Green' } else { 'Red' })

    # Git operations
    $gitCommit = Read-Host "`nDo you want to commit and push to GitHub? (y/N)"
    if ($gitCommit.ToLower() -eq 'y') {
        Write-Step "Preparing Git commit..."
        
        git add .
        $commitMessage = "🚀 Release v$Version - Android & Windows builds ready

✅ Features:
- Android 14 compatible APK 
- Windows desktop EXE
- Subscription-only monetization
- Enhanced Binance API integration

📱 Android: API 26+ (ARM64)
🖥️ Windows: 10+ (x64)
💰 Pricing: \$5/month | \$100/year"

        git commit -m $commitMessage
        git tag -a "v$Version" -m "Release version $Version"
        git push origin main
        git push origin "v$Version"
        
        Write-Host "🚀 Pushed to GitHub! Check Actions: https://github.com/Rk13termux/BINA-BOT/actions" -ForegroundColor Green
    }

} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
} finally {
    Write-Host "`nPress any key to exit..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}
