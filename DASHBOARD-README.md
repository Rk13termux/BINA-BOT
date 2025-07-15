# INVICTUS TRADER PRO - Dashboard Profesional

## 🚀 Descripción del Proyecto

**Invictus Trader Pro** es una aplicación profesional de trading de criptomonedas con un dashboard avanzado que incluye análisis en tiempo real, indicadores técnicos profesionales, y gestión completa de portfolio.

## ✨ Características Principales

### 🎯 Dashboard Profesional
- **Menú Flotante Estilo Widget**: Menú desplegable profesional con acceso rápido a configuraciones
- **Selector de Criptomonedas Avanzado**: Búsqueda y selección de todas las criptomonedas disponibles
- **Precios en Tiempo Real**: WebSocket connection para actualizaciones instantáneas
- **Portfolio Balance**: Visualización completa de balances y criptomonedas

### 📊 Indicadores Técnicos (100+ Indicadores)
- **Tendencia**: SMA, EMA, MACD, ADX, Parabolic SAR, Aroon
- **Momentum**: RSI, Stochastic, CCI, Williams %R, ROC, Ultimate Oscillator
- **Volatilidad**: Bollinger Bands, ATR, Keltner Channels, Donchian Channels
- **Volumen**: OBV, A/D Line, Chaikin Oscillator, MFI, PVT
- **Soporte/Resistencia**: Pivot Points, Fibonacci Retracements, Camarilla
- **Ichimoku**: Sistema completo Ichimoku con nube, Tenkan, Kijun, Senkou

### 🔐 Configuración de APIs Segura
- **Sin APIs Preconfiguradas**: La aplicación está completamente limpia
- **Configuración Manual Obligatoria**: El usuario debe ingresar sus propias credenciales
- **Almacenamiento Seguro**: Encriptación local con Flutter Secure Storage
- **Binance API**: Soporte completo para TestNet y MainNet
- **Groq AI**: Integración con IA para análisis de mercado

### ⚡ Conexiones en Tiempo Real
- **WebSocket Binance**: Conexión directa para precios en tiempo real
- **Sincronización API**: Limitación inteligente de llamadas API
- **Reconexión Automática**: Sistema robusto de reconexión
- **Indicadores Live**: Actualización en tiempo real de todos los indicadores

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada principal
├── core/                              # Funcionalidades core
│   ├── api_manager.dart              # Gestión de APIs
│   └── websocket_manager.dart        # Gestión de WebSockets
├── features/
│   ├── splash/                       # Pantalla de inicio
│   ├── dashboard/
│   │   ├── screens/
│   │   │   └── professional_trading_dashboard.dart  # Dashboard principal
│   │   └── widgets/
│   │       ├── floating_menu_widget.dart           # Menú flotante
│   │       ├── crypto_selector_widget.dart         # Selector de cryptos
│   │       ├── real_time_prices_widget.dart        # Precios en tiempo real
│   │       ├── portfolio_balance_widget.dart       # Balance del portfolio
│   │       └── technical_indicators_widget.dart    # 100+ Indicadores
│   ├── api_config/
│   │   └── professional_api_config_screen.dart     # Configuración de APIs
│   └── settings/                     # Configuraciones
├── services/                         # Servicios de negocio
│   ├── binance_service.dart         # Servicio Binance
│   ├── binance_websocket_service.dart # WebSocket Binance
│   ├── data_stream_service.dart     # Stream de datos en tiempo real
│   └── ai_service.dart              # Servicio de IA
├── models/                          # Modelos de datos
├── ui/
│   ├── theme/                       # Tema de la aplicación
│   └── widgets/                     # Widgets reutilizables
└── utils/                           # Utilidades
```

## 🔧 Configuración Inicial

### 1. APIs Requeridas

La aplicación **NO incluye APIs preconfiguradas**. Debe configurar:

#### 🔸 Binance API
1. Vaya a [Binance.com](https://binance.com) → Account → API Management
2. Cree una nueva API Key con nombre "InvictusTrader"
3. Habilite permisos: "Spot & Margin Trading" + "Futures"
4. Copie ambas keys (API Key y Secret Key)
5. Use TestNet para pruebas iniciales

#### 🔸 Groq AI (Opcional)
1. Vaya a [console.groq.com](https://console.groq.com)
2. Regístrese o inicie sesión
3. Navegue a "API Keys"
4. Cree una nueva API Key
5. Copie la key inmediatamente

### 2. Configuración en la App

1. Abra la aplicación
2. Use el **menú flotante** (botón dorado en la esquina superior derecha)
3. Seleccione "Configurar APIs"
4. Complete los formularios con sus credenciales
5. Pruebe las conexiones antes de continuar

## 🎯 Funcionalidades del Dashboard

### Menú Flotante Desplegable
- **Configurar APIs**: Acceso directo a configuración de credenciales
- **Indicadores**: Configuración de indicadores técnicos
- **Configuración**: Ajustes generales de la aplicación
- **Ayuda**: Información y soporte

### Selector de Criptomonedas
- **Búsqueda Avanzada**: Busque por símbolo o nombre
- **Criptomonedas Populares**: Acceso rápido a las principales
- **Todos los Pares**: Acceso a todos los pares de trading de Binance
- **Timeframes**: 15 timeframes desde 1 minuto hasta 1 mes

### Precios en Tiempo Real
- **WebSocket Live**: Actualizaciones instantáneas de precios
- **Indicador de Conexión**: Estado visual de la conexión
- **Watchlist**: Monitoreo de múltiples criptomonedas
- **Cambios de Precio**: Indicadores visuales de subidas/bajadas

### Portfolio Balance
- **Balance Total**: Valor total en USDT
- **Lista de Criptomonedas**: Todas sus holdings
- **Balance Libre vs Bloqueado**: Diferenciación clara
- **Actualización Automática**: Sincronización con Binance

### Indicadores Técnicos (100+)
- **Categorías Organizadas**: 6 categorías principales
- **Selección Múltiple**: Active/desactive indicadores
- **Valores en Tiempo Real**: Cálculo automático
- **Configuración Flexible**: Personalice parámetros

## 🔒 Seguridad

- **Sin Credenciales Hardcodeadas**: Aplicación completamente limpia
- **Flutter Secure Storage**: Encriptación local de credenciales
- **TestNet Support**: Pruebas seguras antes de trading real
- **API Permissions**: Solo permisos necesarios
- **Rate Limiting**: Respeto a límites de API de Binance

## 🚀 Compilación

### Desarrollo
```bash
flutter run
```

### Producción (APK)
```bash
flutter build apk --release
```

### Producción (Bundle)
```bash
flutter build appbundle --release
```

## 📱 Plataformas Soportadas

- ✅ **Android**: APK y Google Play Store
- ✅ **iOS**: App Store
- ✅ **Web**: PWA (Progressive Web App)
- ✅ **Windows**: Aplicación de escritorio
- ✅ **macOS**: Aplicación de escritorio
- ✅ **Linux**: Aplicación de escritorio

## 🎨 Diseño Visual

### Tema Negro Profesional
- **Color Principal**: Negro puro (#000000)
- **Acentos Dorados**: #FFD700 para elementos importantes
- **Gradientes Sutiles**: Negro a gris muy oscuro
- **Indicadores de Estado**: Verde/Rojo para conexiones
- **Transparencias**: Elementos semi-transparentes para profundidad

### Animaciones
- **Menú Flotante**: Animación de expansión suave
- **Precios**: Flash visual en cambios de precio
- **Indicadores**: Animaciones de carga y actualización
- **Conexión**: Pulso para indicador de tiempo real

## 📋 Requisitos Técnicos

- **Flutter**: 3.x o superior
- **Dart**: 3.x o superior
- **Android**: API level 21+ (Android 5.0)
- **iOS**: iOS 12.0+
- **Conexión a Internet**: Requerida para funcionamiento

## 🔄 Estados de la Aplicación

1. **Splash Screen**: Inicialización y carga
2. **Dashboard Principal**: Pantalla principal sin APIs
3. **Configuración de APIs**: Configuración obligatoria
4. **Dashboard Activo**: Funcionalidad completa con APIs configuradas

## 🎯 Próximas Funcionalidades

- **Trading Directo**: Órdenes desde el dashboard
- **Alertas Personalizadas**: Notificaciones configurables
- **Análisis IA**: Insights automáticos con Groq AI
- **Backtesting**: Pruebas de estrategias históricas
- **Portfolio Analytics**: Análisis avanzado de rendimiento

## 📞 Soporte

Para soporte técnico o preguntas sobre la aplicación:
- **GitHub Issues**: Reporte bugs y solicite características
- **Documentación**: Consulte este README
- **Ayuda en App**: Use el botón "Ayuda" en el menú flotante

---

**Invictus Trader Pro** - Trading profesional sin límites 🚀📈
