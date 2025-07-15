# 🎨 Script para crear logo - Invictus Trader Pro
# PowerShell script para Windows

Write-Host "🎨 INVICTUS TRADER PRO - GUÍA DE LOGO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "📋 PASOS PARA CREAR EL LOGO:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 🎨 DISEÑO RECOMENDADO:" -ForegroundColor Green
Write-Host "   • Estilo: Profesional, elegante, trading"
Write-Host "   • Colores: Dorado (#FFD700) sobre fondo oscuro"
Write-Host "   • Elementos: Corona, gráfico, símbolo de poder"
Write-Host "   • Texto: 'INVICTUS' o 'IT' (opcional)"
Write-Host ""

Write-Host "2. 📐 ESPECIFICACIONES:" -ForegroundColor Green
Write-Host "   • Tamaño principal: 512x512px"
Write-Host "   • Formato: PNG con transparencia"
Write-Host "   • Nombre: logo.png"
Write-Host "   • Ubicación: assets/images/logo.png"
Write-Host ""

Write-Host "3. 🔧 HERRAMIENTAS GRATUITAS:" -ForegroundColor Green
Write-Host "   • Canva: https://canva.com (Fácil, plantillas)"
Write-Host "   • GIMP: https://gimp.org (Completo, gratuito)"
Write-Host "   • Paint.NET: https://getpaint.net (Windows)"
Write-Host "   • Figma: https://figma.com (Online, profesional)"
Write-Host ""

Write-Host "4. ⚡ GENERACIÓN AUTOMÁTICA:" -ForegroundColor Green
Write-Host "   Después de crear assets/images/logo.png:"
Write-Host "   > flutter pub get"
Write-Host "   > flutter pub run flutter_launcher_icons:main"
Write-Host ""

Write-Host "5. 🚀 COMPILACIÓN FINAL:" -ForegroundColor Green
Write-Host "   > flutter build apk --release"
Write-Host "   > git add ."
Write-Host "   > git commit -m '🎨 Added logo and final build'"
Write-Host "   > git push origin main"
Write-Host ""

Write-Host "💡 IDEA RÁPIDA:" -ForegroundColor Magenta
Write-Host "Si necesitas algo rápido, crea:"
Write-Host "• Círculo dorado (#FFD700)"
Write-Host "• Texto 'IT' en el centro (negro, bold)"
Write-Host "• Opcional: ícono 📊 o 👑"
Write-Host ""

Write-Host "📁 ESTRUCTURA DE ARCHIVOS:" -ForegroundColor Blue
Write-Host "assets/images/"
Write-Host "├── logo.png           (512x512px - Principal)"
Write-Host "├── logo_small.png     (256x256px - Pequeño)"
Write-Host "└── logo_icon.png      (192x192px - Icono)"
Write-Host ""

Write-Host "✅ ¡Una vez que tengas el logo, estarás listo para compilar!" -ForegroundColor Green

# Verificar si existe el directorio de imágenes
if (Test-Path "assets\images") {
    Write-Host "✅ Directorio assets/images existe" -ForegroundColor Green
} else {
    Write-Host "❌ Directorio assets/images no encontrado" -ForegroundColor Red
    Write-Host "Creando directorio..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "assets\images" -Force
    Write-Host "✅ Directorio creado" -ForegroundColor Green
}

# Verificar logo existente
if (Test-Path "assets\images\logo.png") {
    Write-Host "✅ Logo encontrado: assets/images/logo.png" -ForegroundColor Green
    Write-Host "¡Puedes proceder con la compilación!" -ForegroundColor Green
} else {
    Write-Host "⏳ Logo no encontrado. Crea assets/images/logo.png primero." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 SIGUIENTE PASO: Crear el archivo assets/images/logo.png" -ForegroundColor Cyan
