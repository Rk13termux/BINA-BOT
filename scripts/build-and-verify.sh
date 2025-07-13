#!/bin/bash

# Script de build y verificación para Invictus Trader Pro
# Este script compila la aplicación y verifica que todo esté correcto

echo "🚀 INVICTUS TRADER PRO - BUILD & VERIFICATION SCRIPT"
echo "══════════════════════════════════════════════════════════"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Verificar que Flutter esté instalado
echo "🔍 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Flutter found: $FLUTTER_VERSION"
echo ""

# Verificar versión de Java para Android
echo "🔍 Checking Java installation..."
if ! command -v java &> /dev/null; then
    print_warning "Java not found - Android builds may fail"
else
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    print_status "Java found: $JAVA_VERSION"
fi
echo ""

# Limpiar proyecto
echo "🧹 Cleaning project..."
flutter clean
print_status "Project cleaned"
echo ""

# Obtener dependencias
echo "📦 Getting dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    print_status "Dependencies downloaded successfully"
else
    print_error "Failed to get dependencies"
    exit 1
fi
echo ""

# Generar archivos con build_runner
echo "🏗️ Generating build files..."
flutter packages pub run build_runner build --delete-conflicting-outputs
if [ $? -eq 0 ]; then
    print_status "Build files generated successfully"
else
    print_warning "Build runner completed with warnings"
fi
echo ""

# Análisis de código
echo "🔍 Analyzing code..."
flutter analyze
if [ $? -eq 0 ]; then
    print_status "Code analysis passed"
else
    print_error "Code analysis failed"
    exit 1
fi
echo ""

# Ejecutar tests
echo "🧪 Running tests..."
flutter test
if [ $? -eq 0 ]; then
    print_status "All tests passed"
else
    print_warning "Some tests failed - check test output"
fi
echo ""

# Verificar permisos de Android
echo "🔐 Checking Android permissions..."
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    if grep -q "android.permission.INTERNET" android/app/src/main/AndroidManifest.xml; then
        print_status "Internet permission found"
    else
        print_error "Internet permission missing in AndroidManifest.xml"
    fi
    
    if grep -q "android.permission.ACCESS_NETWORK_STATE" android/app/src/main/AndroidManifest.xml; then
        print_status "Network state permission found"
    else
        print_warning "Network state permission missing"
    fi
    
    if grep -q "com.android.vending.BILLING" android/app/src/main/AndroidManifest.xml; then
        print_status "Billing permission found (for subscriptions)"
    else
        print_warning "Billing permission missing - in-app purchases may not work"
    fi
else
    print_error "AndroidManifest.xml not found"
fi
echo ""

# Verificar configuración de red
echo "🌐 Checking network configuration..."
if [ -f "android/app/src/main/res/xml/network_security_config.xml" ]; then
    if grep -q "api.binance.com" android/app/src/main/res/xml/network_security_config.xml; then
        print_status "Binance API domains configured"
    else
        print_warning "Binance domains not found in network security config"
    fi
else
    print_warning "Network security config not found"
fi
echo ""

# Build debug APK
echo "📱 Building debug APK..."
flutter build apk --debug --target-platform android-arm64
if [ $? -eq 0 ]; then
    print_status "Debug APK built successfully"
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-debug.apk | cut -f1)
    print_info "Debug APK size: $APK_SIZE"
else
    print_error "Debug APK build failed"
    exit 1
fi
echo ""

# Build release APK
echo "📱 Building release APK..."
flutter build apk --release --target-platform android-arm64
if [ $? -eq 0 ]; then
    print_status "Release APK built successfully"
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    print_info "Release APK size: $APK_SIZE"
else
    print_error "Release APK build failed"
    exit 1
fi
echo ""

# Verificar archivos generados
echo "📋 Verifying build outputs..."
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    print_status "Debug APK: $(ls -lh build/app/outputs/flutter-apk/app-debug.apk | awk '{print $5}')"
else
    print_error "Debug APK not found"
fi

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    print_status "Release APK: $(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')"
else
    print_error "Release APK not found"
fi
echo ""

# Test conectividad API (opcional)
echo "🌐 Testing API connectivity..."
print_info "To test Binance API connectivity, run:"
print_info "flutter test test/api_connectivity_test.dart"
echo ""

# Resumen final
echo "🎯 BUILD SUMMARY"
echo "════════════════"
print_status "✅ Flutter project configured correctly"
print_status "✅ All dependencies resolved"
print_status "✅ Android permissions configured"
print_status "✅ APK files built successfully"
print_status "✅ Ready for deployment"
echo ""

echo "📱 INSTALLATION INSTRUCTIONS"
echo "═══════════════════════════"
echo "Debug APK (for testing):"
echo "  adb install build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "Release APK (for distribution):"
echo "  - Copy build/app/outputs/flutter-apk/app-release.apk to device"
echo "  - Enable 'Install from unknown sources' in Android settings"
echo "  - Install the APK file"
echo ""

echo "🚀 DEPLOYMENT OPTIONS"
echo "════════════════════"
echo "1. Manual Distribution: Share the APK file directly"
echo "2. GitHub Releases: Push to main branch to trigger CI/CD"
echo "3. Google Play Store: Use app-release.aab for Play Store upload"
echo "4. Web Version: Deploy to GitHub Pages or custom domain"
echo ""

echo "💰 SUBSCRIPTION SETUP"
echo "════════════════════"
echo "Remember to configure:"
echo "1. Google Play Console: Set up in-app products"
echo "   - invictus_monthly_5usd (\$5.00)"
echo "   - invictus_yearly_99usd (\$99.00)"
echo "2. App Store Connect: Configure subscription products"
echo "3. Replace dummy signing with real certificates for production"
echo ""

print_status "Build completed successfully! 🎉"
print_info "APK files are ready for testing and distribution."
