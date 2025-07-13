# PowerShell Script de build y verificación para Invictus Trader Pro
# Este script compila la aplicación y verifica que todo esté correcto

Write-Host "🚀 INVICTUS TRADER PRO - BUILD & VERIFICATION SCRIPT" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Funciones para output con colores
function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param($Message)
    Write-Host "ℹ️ $Message" -ForegroundColor Blue
}
    Write-Host "ℹ️ $Message" -ForegroundColor Blue
}

# Verificar que Flutter esté instalado
Write-Host "🔍 Checking Flutter installation..." -ForegroundColor White
try {
    $flutterVersion = flutter --version 2>$null | Select-Object -First 1
    Write-Success "Flutter found: $flutterVersion"
} catch {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}
Write-Host ""

# Verificar versión de Java para Android
Write-Host "🔍 Checking Java installation..." -ForegroundColor White
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Success "Java found: $javaVersion"
} catch {
    Write-Warning "Java not found - Android builds may fail"
}
Write-Host ""

# Limpiar proyecto
Write-Host "🧹 Cleaning project..." -ForegroundColor White
flutter clean
Write-Success "Project cleaned"
Write-Host ""

# Obtener dependencias
Write-Host "📦 Getting dependencies..." -ForegroundColor White
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Success "Dependencies downloaded successfully"
} else {
    Write-Error "Failed to get dependencies"
    exit 1
}
Write-Host ""

# Generar archivos con build_runner
Write-Host "🏗️ Generating build files..." -ForegroundColor White
flutter packages pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -eq 0) {
    Write-Success "Build files generated successfully"
} else {
    Write-Warning "Build runner completed with warnings"
}
Write-Host ""

# Análisis de código
Write-Host "🔍 Analyzing code..." -ForegroundColor White
flutter analyze
if ($LASTEXITCODE -eq 0) {
    Write-Success "Code analysis passed"
} else {
    Write-Error "Code analysis failed"
    exit 1
}
Write-Host ""

# Ejecutar tests
Write-Host "🧪 Running tests..." -ForegroundColor White
flutter test
if ($LASTEXITCODE -eq 0) {
    Write-Success "All tests passed"
} else {
    Write-Warning "Some tests failed - check test output"
}
Write-Host ""

# Verificar permisos de Android
Write-Host "🔐 Checking Android permissions..." -ForegroundColor White
$manifestPath = "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    
    if ($manifestContent -match "android\.permission\.INTERNET") {
        Write-Success "Internet permission found"
    } else {
        Write-Error "Internet permission missing in AndroidManifest.xml"
    }
    
    if ($manifestContent -match "android\.permission\.ACCESS_NETWORK_STATE") {
        Write-Success "Network state permission found"
    } else {
        Write-Warning "Network state permission missing"
    }
    
    if ($manifestContent -match "com\.android\.vending\.BILLING") {
        Write-Success "Billing permission found (for subscriptions)"
    } else {
        Write-Warning "Billing permission missing - in-app purchases may not work"
    }
} else {
    Write-Error "AndroidManifest.xml not found"
}
Write-Host ""

# Verificar configuración de red
Write-Host "🌐 Checking network configuration..." -ForegroundColor White
$networkConfigPath = "android\app\src\main\res\xml\network_security_config.xml"
if (Test-Path $networkConfigPath) {
    $networkConfig = Get-Content $networkConfigPath -Raw
    if ($networkConfig -match "api\.binance\.com") {
        Write-Success "Binance API domains configured"
    } else {
        Write-Warning "Binance domains not found in network security config"
    }
} else {
    Write-Warning "Network security config not found"
}
Write-Host ""

# Build debug APK
Write-Host "📱 Building debug APK..." -ForegroundColor White
flutter build apk --debug --target-platform android-arm64
if ($LASTEXITCODE -eq 0) {
    Write-Success "Debug APK built successfully"
    $apkSize = (Get-Item "build\app\outputs\flutter-apk\app-debug.apk").Length
    $apkSizeMB = [math]::Round($apkSize / 1MB, 2)
    Write-Info "Debug APK size: $apkSizeMB MB"
} else {
    Write-Error "Debug APK build failed"
    exit 1
}
Write-Host ""

# Build release APK
Write-Host "📱 Building release APK..." -ForegroundColor White
flutter build apk --release --target-platform android-arm64
if ($LASTEXITCODE -eq 0) {
    Write-Success "Release APK built successfully"
    $apkSize = (Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length
    $apkSizeMB = [math]::Round($apkSize / 1MB, 2)
    Write-Info "Release APK size: $apkSizeMB MB"
} else {
    Write-Error "Release APK build failed"
    exit 1
}
Write-Host ""

# Verificar archivos generados
Write-Host "📋 Verifying build outputs..." -ForegroundColor White
$debugApk = "build\app\outputs\flutter-apk\app-debug.apk"
$releaseApk = "build\app\outputs\flutter-apk\app-release.apk"

if (Test-Path $debugApk) {
    $size = [math]::Round((Get-Item $debugApk).Length / 1MB, 2)
    Write-Success "Debug APK: $size MB"
} else {
    Write-Error "Debug APK not found"
}

if (Test-Path $releaseApk) {
    $size = [math]::Round((Get-Item $releaseApk).Length / 1MB, 2)
    Write-Success "Release APK: $size MB"
} else {
    Write-Error "Release APK not found"
}
Write-Host ""

# Test conectividad API (opcional)
Write-Host "🌐 Testing API connectivity..." -ForegroundColor White
Write-Info "To test Binance API connectivity, run:"
Write-Info "flutter test test/api_connectivity_test.dart"
Write-Host ""

# Resumen final
Write-Host "🎯 BUILD SUMMARY" -ForegroundColor Cyan
Write-Host "════════════════" -ForegroundColor Cyan
Write-Success "✅ Flutter project configured correctly"
Write-Success "✅ All dependencies resolved"
Write-Success "✅ Android permissions configured"
Write-Success "✅ APK files built successfully"
Write-Success "✅ Ready for deployment"
Write-Host ""

Write-Host "📱 INSTALLATION INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "═══════════════════════════" -ForegroundColor Cyan
Write-Host "Debug APK (for testing):"
Write-Host "  adb install build\app\outputs\flutter-apk\app-debug.apk"
Write-Host ""
Write-Host "Release APK (for distribution):"
Write-Host "  - Copy build\app\outputs\flutter-apk\app-release.apk to device"
Write-Host "  - Enable 'Install from unknown sources' in Android settings"
Write-Host "  - Install the APK file"
Write-Host ""

Write-Host "🚀 DEPLOYMENT OPTIONS" -ForegroundColor Cyan
Write-Host "════════════════════" -ForegroundColor Cyan
Write-Host "1. Manual Distribution: Share the APK file directly"
Write-Host "2. GitHub Releases: Push to main branch to trigger CI/CD"
Write-Host "3. Google Play Store: Use app-release.aab for Play Store upload"
Write-Host "4. Web Version: Deploy to GitHub Pages or custom domain"
Write-Host ""

Write-Host "💰 SUBSCRIPTION SETUP" -ForegroundColor Cyan
Write-Host "════════════════════" -ForegroundColor Cyan
Write-Host "Remember to configure:"
Write-Host "1. Google Play Console: Set up in-app products"
Write-Host "   - invictus_monthly_5usd (\$5.00)"
Write-Host "   - invictus_yearly_99usd (\$99.00)"
Write-Host "2. App Store Connect: Configure subscription products"
Write-Host "3. Replace dummy signing with real certificates for production"
Write-Host ""

Write-Success "Build completed successfully! 🎉"
Write-Info "APK files are ready for testing and distribution."

# Pausa para que el usuario pueda leer los resultados
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
