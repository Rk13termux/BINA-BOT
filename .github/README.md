# Invictus Trader Pro - GitHub Actions CI/CD

Professional cryptocurrency trading application with automated build pipeline for Android and Windows platforms.

## 🚀 Quick Start

### Manual Build Trigger
1. Go to **Actions** in your GitHub repository
2. Select **"Build Invictus Trader Pro (APK & EXE)"**
3. Click **"Run workflow"**
4. Select build type (release/debug)
5. Click **"Run workflow"**

### Local Build Scripts
```bash
# Windows Batch Script
./scripts/build-release.bat

# PowerShell Script (Enhanced)
./scripts/build-release.ps1

# With options
./scripts/build-release.ps1 -Debug -SkipTests
```

## 🔄 Automated Workflows

### 1. **Build Workflow** (`build.yml`)
- **Triggers**: Push to `main`/`develop`, Pull Requests, Manual
- **Platforms**: Android (APK) + Windows (EXE)
- **Outputs**: 
  - `invictus-trader-android-apk` - ARM64 optimized APK
  - `invictus-trader-windows-exe` - x64 desktop application

### 2. **Multi-Platform Support**
- **Android**: API 26+ (Android 8.0 to 15)
- **Windows**: Windows 10/11 (64-bit)
- **Architecture**: ARM64 (Android), x64 (Windows)
## 📱 Application Features

### � Monetization Model
- **Monthly Subscription**: $5.00/month
- **Yearly Subscription**: $100.00/year (50% savings)
- **No Ads**: Premium experience only
- **Features**: Advanced trading tools, AI analysis, real-time data

### 🔐 Security & Compatibility
- **Android 14 Ready**: Full compatibility with latest Android versions
- **Secure Storage**: Encrypted subscription and user data
- **Network Security**: Configured for Binance API communications
- **Backup Rules**: Android-compliant data backup policies

## 🎯 Build Artifacts

### Android APK
- **File**: `InvictusTraderPro-Android-vX.X.X.apk`
- **Size**: ~88 MB (optimized)
- **Target**: ARM64 devices (recommended)
- **Compatibility**: Android 8.0+ (API 26 to 34)
- **Features**: Production-ready, signed, optimized

### Windows EXE  
- **File**: `InvictusTraderPro-Windows-vX.X.X.zip`
- **Size**: ~150 MB (compressed)
- **Target**: Windows 10/11 (64-bit)
- **Features**: Desktop app, no installation required

## 🔧 Configuración de Secrets

Para compilaciones de release firmadas, añade estos secrets en tu repositorio:

### Android Signing (Opcional)
```
ANDROID_KEYSTORE_BASE64  # Keystore en base64
ANDROID_KEY_ALIAS        # Alias de la clave
ANDROID_KEY_PASSWORD     # Contraseña de la clave
ANDROID_STORE_PASSWORD   # Contraseña del keystore
```

### Generar Keystore
```bash
keytool -genkey -v -keystore bina-bot-release-key.keystore \
        -alias binabot -keyalg RSA -keysize 2048 -validity 10000
```

Luego convertir a base64:
```bash
base64 -i bina-bot-release-key.keystore | tr -d '\n' | pbcopy
```

## 📊 Estado de Builds

| Workflow | Status |
|----------|--------|
| Build | [![Build Status](../../actions/workflows/build.yml/badge.svg)](../../actions/workflows/build.yml) |
| Tests | [![Test Status](../../actions/workflows/test.yml/badge.svg)](../../actions/workflows/test.yml) |
| Release | [![Release Status](../../actions/workflows/release.yml/badge.svg)](../../actions/workflows/release.yml) |

## 🎯 Estrategia de Branches

- **`main`**: Builds de release automáticos
- **`develop`**: Builds de debug automáticos
- **Feature branches**: Solo ejecutan tests

## 📋 Checklist de Release

- [ ] Actualizar versión en `pubspec.yaml`
- [ ] Ejecutar tests locales
- [ ] Crear tag de Git
- [ ] Push tag al repositorio
- [ ] Verificar que el workflow se ejecute correctamente
- [ ] Descargar y verificar artefactos
- [ ] Actualizar documentation si es necesario

## 🔗 Enlaces Útiles

- [Flutter GitHub Actions](https://github.com/marketplace/actions/flutter-action)
- [Android Signing](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Windows Desktop Support](https://docs.flutter.dev/platform-integration/windows/building)
