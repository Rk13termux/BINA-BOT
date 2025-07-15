#!/bin/bash
# Script para crear un logo temporal simple

echo "🎨 Creando logo temporal para Invictus Trader Pro..."

# Crear un logo simple con ImageMagick (si está disponible)
# Si no tienes ImageMagick, usa cualquier editor gráfico para crear:
# - Un círculo dorado (#FFD700)
# - Texto "IT" en el centro
# - Tamaño 512x512px
# - Fondo transparente

echo "📋 INSTRUCCIONES PARA CREAR EL LOGO:"
echo ""
echo "1. Abre cualquier editor gráfico (Canva, GIMP, Paint.NET, etc.)"
echo "2. Crea un nuevo documento de 512x512px"
echo "3. Fondo: Transparente"
echo "4. Dibuja un círculo dorado (#FFD700)"
echo "5. Agrega texto 'IT' en el centro (negro, bold)"
echo "6. Opcional: Agrega un ícono de gráfico 📊"
echo "7. Exporta como PNG: assets/images/logo.png"
echo ""
echo "🔧 HERRAMIENTAS RECOMENDADAS:"
echo "   • Canva (gratuito): https://canva.com"
echo "   • GIMP (gratuito): https://gimp.org"
echo "   • Paint.NET (Windows): https://getpaint.net"
echo ""
echo "📐 TAMAÑOS NECESARIOS:"
echo "   • logo.png (512x512px) - Principal"
echo "   • logo_small.png (256x256px) - Pequeño"
echo "   • logo_icon.png (192x192px) - Icono"
echo ""
echo "⚡ GENERACIÓN AUTOMÁTICA:"
echo "   Después de crear logo.png, ejecuta:"
echo "   flutter pub get"
echo "   flutter pub run flutter_launcher_icons:main"
echo ""
echo "✅ ¡Luego estarás listo para compilar!"
