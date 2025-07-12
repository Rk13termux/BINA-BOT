# BINA-BOT GitHub Actions CI/CD

Este proyecto utiliza GitHub Actions para compilar automáticamente las versiones de Android (APK) y Windows (EXE).

## 🔄 Workflows Disponibles.

### 1. **Build Workflow** (`build.yml`)
- **Trigger**: Push a `main` o `develop`, Pull Requests, Manual
- **Función**: Compila APK y EXE automáticamente
- **Outputs**: 
  - Android APKs (arm64, armv7, x86_64)
  - Windows EXE (comprimido en ZIP)

### 2. **Test Workflow** (`test.yml`)
- **Trigger**: Push y Pull Requests
- **Función**: Ejecuta tests y análisis de código
- **Outputs**: Reportes de cobertura

### 3. **Release Workflow** (`release.yml`)
- **Trigger**: Tags `v*` o manual
- **Función**: Crea releases automáticos con artefactos

## 🚀 Cómo Usar

### Compilar Manualmente
1. Ve a **Actions** en tu repositorio de GitHub
2. Selecciona **"Build BINA-BOT APK & EXE"**
3. Haz click en **"Run workflow"**
4. Selecciona el tipo de build (debug/release)
5. Haz click en **"Run workflow"**

### Crear Release Automático
1. Ejecuta el script de preparación:
   ```bash
   # Linux/Mac
   ./scripts/prepare-release.sh
   
   # Windows
   ./scripts/prepare-release.bat
   ```

2. Sigue las instrucciones del script para:
   - Actualizar la versión
   - Ejecutar tests
   - Crear tag de Git
   - Push al repositorio

3. GitHub Actions creará automáticamente:
   - Compilación de APK y EXE
   - Release con archivos adjuntos
   - Changelog automático

## 📱 Artefactos Generados

### Android APKs
- `app-arm64-v8a-release.apk` - Para dispositivos ARM64 (recomendado)
- `app-armeabi-v7a-release.apk` - Para dispositivos ARM más antiguos
- `app-x86_64-release.apk` - Para emuladores x86

### Windows EXE
- `bina-bot-windows-release-vX.X.X.zip` - Aplicación Windows completa

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
