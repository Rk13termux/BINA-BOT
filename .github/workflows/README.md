# 🚀 Sistema de Build Unificado - Invictus Trader Pro

## 📋 Descripción General

Este sistema de workflow unificado construye **todas las plataformas** en una sola ejecución:
- 🤖 **Android APK** (Release & Debug)
- 🪟 **Windows EXE** (Standalone)  
- 🌐 **Web App** (Optimizada)

## 🔄 Workflows Disponibles

### 1. 🚀 **Build Unified** (Principal)
**Archivo**: `build-unified.yml`
- **Trigger**: Push a `main` o `develop`, Pull Requests, Manual
- **Función**: Construye todas las plataformas en paralelo
- **Output**: Release unificado con todos los artefactos

### 2. 🧪 **Test** (Calidad)
**Archivo**: `test.yml`  
- **Trigger**: Push y Pull Requests
- **Función**: Ejecuta pruebas y análisis de código
- **Output**: Reportes de calidad

## ⚙️ Configuración del Build Unificado

### 🎯 Estrategia Matrix
```yaml
strategy:
  matrix:
    include:
      - platform: android
        build_command: "flutter build apk --release --split-per-abi"
      - platform: windows  
        build_command: "flutter build windows --release"
      - platform: web
        build_command: "flutter build web --release --web-renderer html"
```

### 🔧 Variables de Entorno
```yaml
env:
  FLUTTER_VERSION: '3.27.1'
  JAVA_VERSION: '11'
  NODE_VERSION: '18'
```

## 🎮 Ejecución Manual

### 1. Desde GitHub UI
1. Ve a **Actions** → **Build Unified**
2. Click **"Run workflow"**
3. Selecciona opciones:
   - **Build Type**: `all`, `android-only`, `windows-only`, `web-only`
   - **Release Version**: Opcional (ej: `1.0.0`)

### 2. Desde CLI
```bash
# Trigger manual con GitHub CLI
gh workflow run build-unified.yml

# Con parámetros específicos
gh workflow run build-unified.yml \
  -f build_type=android-only \
  -f release_version=1.0.1
```

## 📦 Artefactos Generados

### 🤖 Android
```
├── build/app/outputs/flutter-apk/
│   ├── app-arm64-v8a-release.apk
│   ├── app-armeabi-v7a-release.apk
│   └── app-x86_64-release.apk
```

### 🪟 Windows
```
├── build/windows/x64/runner/Release/
│   ├── invictus_trader_pro.exe
│   ├── flutter_windows.dll
│   └── data/
```

### 🌐 Web
```
├── build/web/
│   ├── index.html
│   ├── main.dart.js
│   ├── assets/
│   └── icons/
```

## 🚀 Release Automático

### 📋 Proceso
1. **Build Matrix**: Todas las plataformas en paralelo
2. **Quality Checks**: Análisis de código y tests
3. **Artifact Packaging**: Empaquetado optimizado
4. **Unified Release**: Release GitHub con todos los binarios
5. **Cleanup**: Limpieza automática de artefactos antiguos

### 🏷️ Versionado
- **Manual**: Especifica versión en workflow manual
- **Automático**: `v2025.07.11-build-123` (fecha + build number)

### 📦 Contenido del Release
```
invictus-trader-pro-unified-release.zip
├── android/
│   ├── app-arm64-v8a-release.apk
│   └── app-armeabi-v7a-release.apk
├── windows/
│   ├── invictus_trader_pro.exe
│   └── dependencias/
├── web/
│   ├── index.html
│   └── assets/
└── README.md
```

## ⚡ Optimizaciones Implementadas

### 🔄 Cache Inteligente
- **Flutter SDK**: Cache por versión y OS
- **Dependencies**: Cache por `pubspec.yaml` hash
- **Build Cache**: Reutilización entre builds

### 🏗️ Build Paralelo
- **Matrix Strategy**: 3 platforms en paralelo
- **Resource Optimization**: Compartición eficiente de recursos
- **Timeout Protection**: 60 minutos máximo por platform

### 📊 Monitoring
- **Build Summary**: Reporte detallado en GitHub
- **Artifact Verification**: Validación automática
- **Error Reporting**: Logs detallados para debugging

## 🛠️ Troubleshooting

### ❌ Build Falla en Android
```bash
# Verificar Java y Android SDK
flutter doctor -v
```

### ❌ Build Falla en Windows
```bash
# Verificar Visual Studio Build Tools
flutter config --enable-windows-desktop
```

### ❌ Build Falla en Web
```bash
# Verificar configuración web
flutter config --enable-web
```

### 🔍 Debug Workflow
1. Revisa **Actions** tab en GitHub
2. Examina logs específicos por platform
3. Verifica `flutter doctor` output
4. Comprueba dependencias en `pubspec.yaml`

## 📈 Métricas y Estadísticas

### ⏱️ Tiempos Promedio
- **Android**: ~8-12 minutos
- **Windows**: ~10-15 minutos  
- **Web**: ~5-8 minutos
- **Total Paralelo**: ~15-20 minutos

### 💾 Tamaños de Artefactos
- **Android APK**: ~25-40 MB
- **Windows EXE + DLLs**: ~80-120 MB
- **Web Bundle**: ~15-25 MB

## 🔮 Próximas Mejoras

### 🎯 Roadmap
- [ ] **iOS Build**: Agregar soporte para macOS/iOS
- [ ] **Docker**: Builds containerizados
- [ ] **Auto-Deploy**: Deploy automático a stores
- [ ] **Performance Testing**: Benchmarks automáticos
- [ ] **Security Scanning**: Análisis de vulnerabilidades

## 📞 Soporte

### 🐛 Reportar Issues
- Crear issue en GitHub con logs del workflow
- Incluir platform específica y versión de Flutter
- Adjuntar `flutter doctor -v` output

### 📚 Documentación
- [Flutter Build Docs](https://docs.flutter.dev/deployment)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Project Wiki](../../wiki)

---

## 🎉 ¡Listo para Producción!

El sistema unificado está optimizado para:
- ✅ **Eficiencia**: Builds paralelos y cache inteligente
- ✅ **Reliability**: Error handling y retry logic
- ✅ **Flexibility**: Manual triggers con opciones
- ✅ **Automation**: Release automático en commits a main
- ✅ **Monitoring**: Logs detallados y métricas

**🚀 ¡Tu app multiplatform se construye automáticamente con cada push!**
