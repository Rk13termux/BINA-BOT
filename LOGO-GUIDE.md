# 🎨 GUÍA PARA AGREGAR EL LOGO - INVICTUS TRADER PRO

## 📋 **ARCHIVOS DE LOGO NECESARIOS**

### **1. Logo Principal (assets/images/)**
Coloca estos archivos en: `assets/images/`

```
📁 assets/images/
   ├── logo.png           ← Logo principal (512x512px)
   ├── logo_small.png     ← Logo pequeño (256x256px)
   ├── logo_icon.png      ← Icono cuadrado (192x192px)
   └── splash_logo.png    ← Logo para splash screen (300x300px)
```

### **2. Iconos Android (Requeridos para APK)**
Coloca estos archivos con el nombre: `ic_launcher.png`

```
📁 android/app/src/main/res/
   ├── mipmap-mdpi/ic_launcher.png     ← 48x48px
   ├── mipmap-hdpi/ic_launcher.png     ← 72x72px
   ├── mipmap-xhdpi/ic_launcher.png    ← 96x96px
   ├── mipmap-xxhdpi/ic_launcher.png   ← 144x144px
   └── mipmap-xxxhdpi/ic_launcher.png  ← 192x192px
```

### **3. Iconos iOS (Para compilación iOS)**
```
📁 ios/Runner/Assets.xcassets/AppIcon.appiconset/
   ├── Icon-1024.png      ← 1024x1024px
   ├── Icon-60@2x.png     ← 120x120px
   ├── Icon-60@3x.png     ← 180x180px
   └── [otros tamaños según iOS...]
```

## 🎨 **ESPECIFICACIONES DE DISEÑO**

### **Colores de Marca:**
- **Dorado Principal:** #FFD700
- **Dorado Secundario:** #B8860B
- **Fondo Oscuro:** #1A1A1A
- **Verde Alcista:** #00FF88
- **Rojo Bajista:** #FF4444

### **Elementos Sugeridos:**
```
👑 Corona dorada (INVICTUS = invencible)
📊 Gráfico de candlesticks ascendente
⚡ Rayo dorado (velocidad/poder)
🎯 Diana con flecha (precisión)
💎 Diamante estilizado (premium)
🏛️ Columnas griegas (fuerza/estabilidad)
```

### **Estilo:**
- **Tema:** Profesional, elegante, trading
- **Forma:** Preferiblemente cuadrada para iconos
- **Fondo:** Transparente (PNG)
- **Contraste:** Alto contraste para visibilidad

## 🔧 **HERRAMIENTAS RECOMENDADAS**

### **Para crear el logo:**
- **Canva** (gratuito, plantillas)
- **Figma** (gratis, profesional)
- **Adobe Illustrator** (premium)
- **GIMP** (gratuito, completo)

### **Para generar iconos automáticamente:**
- **flutter_launcher_icons** (plugin Flutter)
- **App Icon Generator** (online)
- **Icon Kitchen** (Android Studio)

## 📱 **INSTALACIÓN AUTOMÁTICA DE ICONOS**

Si quieres generar todos los tamaños automáticamente:

### **1. Agregar dependencia:**
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### **2. Configurar en pubspec.yaml:**
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
  adaptive_icon_background: "#1A1A1A"
  adaptive_icon_foreground: "assets/images/logo.png"
```

### **3. Ejecutar comando:**
```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

## ✅ **VERIFICACIÓN**

Después de agregar los logos:

1. **Verificar archivos:**
   ```bash
   flutter pub get
   flutter clean
   flutter pub get
   ```

2. **Compilar para probar:**
   ```bash
   flutter build apk --debug
   ```

3. **Verificar icono en el dispositivo:**
   - El icono debe aparecer en el menú de aplicaciones
   - Debe verse nítido en diferentes tamaños

## 🚀 **SIGUIENTE PASO**

Una vez que tengas los archivos de logo listos:

1. **Copia los archivos** a las carpetas indicadas
2. **Ejecuta:** `flutter pub get`
3. **Compila:** `flutter build apk --release`
4. **¡Listo para GitHub!**

---

### **🎯 EJEMPLO DE LOGO SIMPLE**

Si necesitas crear uno rápido, puedes usar:
- **Fondo:** Círculo dorado (#FFD700)
- **Texto:** "IT" (Invictus Trader) en negro bold
- **Borde:** Línea dorada más oscura (#B8860B)
- **Tamaño:** 512x512px, exportar en los tamaños requeridos

¡El logo es lo último que falta antes de compilar! 🎨✨
