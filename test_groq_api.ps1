# Script para probar la API de Groq
# Ejecuta el test de conectividad con la API

Write-Host "🚀 Ejecutando pruebas de la API de Groq..." -ForegroundColor Yellow
Write-Host ""

# Verificar que Flutter esté instalado
try {
    $flutterVersion = flutter --version 2>$null
    Write-Host "✅ Flutter encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter no encontrado. Instala Flutter primero." -ForegroundColor Red
    exit 1
}

# Verificar que el archivo de prueba existe
if (-not (Test-Path "test_groq_api.dart")) {
    Write-Host "❌ Archivo test_groq_api.dart no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host "🔧 Instalando dependencias..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "🧪 Ejecutando pruebas de la API..." -ForegroundColor Cyan
Write-Host ""

# Ejecutar el test
dart run test_groq_api.dart

Write-Host ""
Write-Host "📋 Resumen de la prueba:" -ForegroundColor Yellow
Write-Host "- Si ves ✅ en todos los tests, la API está funcionando correctamente" -ForegroundColor White
Write-Host "- Si ves ❌ en algún test, revisa la configuración correspondiente" -ForegroundColor White
Write-Host "- Para configurar tu API key, edita el archivo .env" -ForegroundColor White
