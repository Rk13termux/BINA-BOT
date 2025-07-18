@echo off
REM 🚀 Script de Windows para compilar APK con API integrada

echo 🔨 Compilando Invictus Trader Pro con API de Groq integrada...
echo ============================================================

REM Verificar que Flutter esté instalado
flutter --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Flutter no está instalado
    pause
    exit /b 1
)

echo ✅ Flutter encontrado

REM Limpiar proyecto
echo 🧹 Limpiando proyecto...
flutter clean

REM Obtener dependencias
echo 📦 Obteniendo dependencias...
flutter pub get

REM Verificar que existe el archivo .env
if not exist ".env" (
    echo ❌ Error: No se encontró el archivo .env
    echo 💡 Copia el contenido de MI-CONFIGURACION-PERSONAL.txt al archivo .env
    pause
    exit /b 1
)

echo ✅ Archivo .env encontrado

REM Compilar APK de release
echo 🔨 Compilando APK de release...
flutter build apk --release --split-per-abi

REM Verificar que la APK se compiló correctamente
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    echo 🎉 ¡Compilación exitosa!
    echo.
    echo 📱 APKs generadas:
    dir "build\app\outputs\flutter-apk\*.apk" /b
    echo.
    echo ✅ La APK incluye la API de Groq funcional
    echo 📍 Ubicación principal: build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
    echo.
    echo 🚀 Puedes instalar la APK directamente en tu dispositivo Android
) else (
    echo ❌ Error en la compilación
    pause
    exit /b 1
)

echo 🎯 ¡Compilación completada con API integrada!
pause
