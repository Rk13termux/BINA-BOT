# 🚀 QUANTIX AI CORE
**"Piensa como fondo, opera como elite."**

## 📱 Plataforma de Trading Profesional con IA

QUANTIX AI CORE es una aplicación de trading de criptomonedas de nueva generación que combina:
- **Análisis de IA avanzado** con Groq Llama 3.3 70B
- **Integración directa con Binance**
- **100+ Indicadores técnicos**
- **Arquitectura modular profesional**
- **Seguridad de nivel empresarial**

---

## 🔐 Configuración Segura (Sin .env)

### ✅ **NUEVA ARQUITECTURA DE SEGURIDAD**

**QUANTIX ya NO usa archivos .env** - Todo se configura de forma segura:

1. **📱 Al abrir la app por primera vez:**
   - Onboarding guiado te pide las API keys
   - Se almacenan cifradas con Flutter Secure Storage
   - Cifrado a nivel de dispositivo

2. **🔑 APIs necesarias:**
   - **Groq API** (GRATIS): https://console.groq.com/keys
   - **Binance API**: https://www.binance.com/en/support/faq/360002502072

A professional Flutter trading application for cryptocurrency trading with Binance integration, real-time analysis, and advanced features.

![Flutter](https://img.shields.io/badge/Flutter-3.27.1-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🚀 Features.

### Core Features.
- **Real-time Trading**: Live cryptocurrency market data via Binance WebSocket
- **Professional Charts**: Advanced candlestick charts with technical indicators
- **News Integration**: Real-time crypto news from multiple sources (CoinDesk, CoinTelegraph, etc.)
- **Alert System**: Customizable price alerts and notifications
- **Portfolio Tracking**: Track your investments and P&L analysis
- **Plugin System**: Extensible architecture with custom trading strategies

### Advanced Features
- **AI Analysis**: TensorFlow Lite integration for market analysis
- **Multi-platform**: Android, iOS, Web, and Desktop support
- **Secure Storage**: Encrypted API keys and sensitive data
- **Monetization**: Free tier with ads, Premium tiers with advanced features
- **Dark Theme**: Professional dark theme with gold accents

## 🏗️ Architecture

This project follows **Clean Architecture** principles with:

```
lib/
├── core/           # Core functionality (API, WebSocket, Storage)
├── models/         # Data models and entities
├── features/       # Feature-based modules
│   ├── dashboard/  # Main dashboard
│   ├── trading/    # Trading functionality
│   ├── alerts/     # Alert system
│   ├── news/       # News module
│   ├── plugins/    # Plugin system
│   └── settings/   # App settings
├── services/       # Business logic and external integrations
├── ui/            # UI components and theme
└── utils/         # Utilities and helpers
```

## 🛠️ Getting Started

### Prerequisites
- Flutter 3.27.1 or higher
- Dart SDK 3.7.0 or higher
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/invictustraderapk.git
   cd invictustraderapk
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

### Building for Different Platforms

#### Android APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

#### Windows Desktop
```bash
# Enable Windows desktop
flutter config --enable-windows-desktop

# Build Windows executable
flutter build windows --release
```

#### Web
```bash
# Enable Web
flutter config --enable-web

# Build Web
flutter build web --release
```

#### iOS (macOS only)
```bash
# Build iOS
flutter build ios --release
```

## 🔧 Configuration

### API Keys Setup

1. Create a `.env` file in the root directory:
   ```env
   BINANCE_API_KEY=your_binance_api_key
   BINANCE_SECRET_KEY=your_binance_secret_key
   ADMOB_APP_ID_ANDROID=your_android_admob_app_id
   ADMOB_APP_ID_IOS=your_ios_admob_app_id
   ```

2. Update `lib/utils/constants.dart` with your configuration

### Firebase Setup (Optional)
1. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
2. Configure Firebase Console for your project

## 🚀 GitHub Actions CI/CD

This project includes automated building for multiple platforms:

### Automatic Builds
- **Android APK**: Debug and Release APKs
- **Windows EXE**: Desktop executable with installer
- **Web Build**: Deployable web version

### Manual Release
1. Push to `main` branch
2. GitHub Actions will automatically:
   - Build all platforms
   - Run tests and analysis
   - Create a release with downloadable assets

### Manual Workflow Dispatch
You can manually trigger builds from the GitHub Actions tab.

## 📱 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | API Level 21+ |
| iOS | ✅ Full Support | iOS 12+ |
| Web | ✅ Full Support | Modern browsers |
| Windows | ✅ Full Support | Windows 10+ |
| macOS | ⚠️ Limited | Requires macOS for building |
| Linux | ⚠️ Limited | Experimental support |

## 🔐 Security Features

- **Encrypted Storage**: All sensitive data encrypted with Flutter Secure Storage
- **API Security**: Secure API key management
- **Plugin Sandbox**: Safe plugin execution environment
- **Input Validation**: Comprehensive input validation and sanitization

## 🎯 Performance

- **Real-time Updates**: Efficient WebSocket connections
- **Memory Management**: Optimized for mobile devices
- **Caching**: Smart caching for offline capability
- **Lazy Loading**: Efficient resource loading

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## � Dependencies

### Key Dependencies
- `provider`: State management
- `hive`: Local database
- `flutter_secure_storage`: Secure storage
- `web_socket_channel`: WebSocket connections
- `candlesticks`: Chart widgets
- `google_mobile_ads`: Monetization
- `in_app_purchase`: Subscription management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/invictustraderapk/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/invictustraderapk/discussions)
- **Documentation**: [Wiki](https://github.com/your-username/invictustraderapk/wiki)

## 🏆 Acknowledgments

- Flutter team for the amazing framework
- Binance for the trading API
- Contributors and testers
- Open source community

---

**⚠️ Disclaimer**: This is a trading application. Trading cryptocurrencies involves risk. Use at your own discretion and never invest more than you can afford to lose. 
- **x86_64** (Emuladores)

### 💻 Windows EXE
- **Windows x64** (ZIP con ejecutable y dependencias)

## 🌟 Características Principales

### 📈 Trading Profesional
- ✅ Integración completa con Binance API
- ✅ Gráficos de velas en tiempo real
- ✅ Indicadores técnicos avanzados
- ✅ Órdenes de compra/venta automáticas
- ✅ Análisis de portfolio con P&L

### 📰 Noticias Inteligentes
- ✅ Scraping automático de múltiples fuentes (CoinDesk, CoinTelegraph, etc.)
- ✅ Búsqueda y filtros avanzados
- ✅ Categorización automática
- ✅ Historial de búsquedas
- ✅ Sistema de marcadores

### 🔔 Alertas Personalizadas
- ✅ Alertas de precio en tiempo real
- ✅ Alertas de volumen y cambios de mercado
- ✅ Notificaciones push nativas
- ✅ Sistema de alertas inteligentes

### 🔌 Sistema de Plugins
- ✅ Arquitectura modular extensible
- ✅ Plugins personalizados para estrategias
- ✅ Ejecución segura con dart_eval
- ✅ Marketplace de plugins integrado

### 💰 Monetización
- ✅ Versión gratuita con anuncios
- ✅ Suscripciones Premium y Pro
- ✅ Características avanzadas por tiers
- ✅ Integración con Google Ads e In-App Purchases

## 🚀 Instalación Rápida

### Android
1. Ve a [Releases](https://github.com/Rk13termux/BINA-BOT/releases)
2. Descarga el APK para tu arquitectura
3. Instala permitiendo "Fuentes desconocidas"

### Windows
1. Ve a [Releases](https://github.com/Rk13termux/BINA-BOT/releases)
2. Descarga el archivo ZIP
3. Extrae y ejecuta `invictus_trader_pro.exe`

## 🔧 Compilación Automática

Este proyecto utiliza **GitHub Actions** para compilación automática:

- ✅ **Push a main** → Build de release automático
- ✅ **Push a develop** → Build de debug automático  
- ✅ **Pull Request** → Tests automáticos
- ✅ **Tags vX.X.X** → Release automático con APK/EXE

### Compilar Manualmente
```bash
# Ir a Actions en GitHub → "Build BINA-BOT APK & EXE" → "Run workflow"
```

Ver [GitHub Actions Guide](.github/README.md) para más detalles.

## 🏗️ Arquitectura

```
📁 lib/
├── 🎯 core/           # API, WebSocket, Storage
├── 📊 models/         # Modelos de datos
├── 🏠 features/       # Módulos por funcionalidad
│   ├── dashboard/     # Panel principal
│   ├── trading/       # Sistema de trading
│   ├── news/          # Noticias y scraping
│   ├── alerts/        # Sistema de alertas
│   ├── plugins/       # Gestión de plugins
│   └── settings/      # Configuraciones
├── 🎨 ui/            # Temas y componentes
├── 🔧 services/      # Lógica de negocio
└── 🛠️ utils/         # Utilidades y helpers
```

## 🎨 Tecnologías

- **Framework**: Flutter 3.24+ (Multiplataforma)
- **Estado**: Provider Pattern
- **API**: Binance REST + WebSocket
- **Storage**: Hive + Flutter Secure Storage
- **Charts**: Candlesticks + FL Chart
- **Scraping**: HTML Parser
- **AI**: TensorFlow Lite
- **Ads**: Google Mobile Ads
- **Payments**: In-App Purchase

## 📸 Screenshots

| Dashboard | Trading | Noticias | Alertas |
|-----------|---------|----------|---------|
| ![Dashboard](https://via.placeholder.com/200x350/1A1A1A/FFD700?text=Dashboard) | ![Trading](https://via.placeholder.com/200x350/1A1A1A/00FF88?text=Trading) | ![News](https://via.placeholder.com/200x350/1A1A1A/4A90E2?text=News) | ![Alerts](https://via.placeholder.com/200x350/1A1A1A/FF4444?text=Alerts) |

## 🔐 Configuración de APIs

### Binance API
1. Crea cuenta en [Binance](https://binance.com)
2. Genera API Key en configuración
3. Configura en la app: Configuración → API Keys

### Notificaciones
Las notificaciones push están preconfiguradas y funcionan automáticamente.

## 🤝 Contribuir

1. **Fork** este repositorio
2. **Clone** tu fork: `git clone https://github.com/TU_USUARIO/BINA-BOT.git`
3. **Crea** una rama: `git checkout -b feature/nueva-funcionalidad`
4. **Commitea** tus cambios: `git commit -m 'Add: nueva funcionalidad'`
5. **Push** a la rama: `git push origin feature/nueva-funcionalidad`
6. **Abre** un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 🔗 Enlaces

- 📱 [Releases](https://github.com/Rk13termux/BINA-BOT/releases) - Descargas APK/EXE
- 🐛 [Issues](https://github.com/Rk13termux/BINA-BOT/issues) - Reportar bugs
- 💡 [Discussions](https://github.com/Rk13termux/BINA-BOT/discussions) - Ideas y sugerencias
- 📖 [Wiki](https://github.com/Rk13termux/BINA-BOT/wiki) - Documentación completa

## ⭐ Soporte

Si este proyecto te ayuda, ¡considera darle una estrella ⭐!

[![Star History Chart](https://api.star-history.com/svg?repos=Rk13termux/BINA-BOT&type=Timeline)](https://star-history.com/#Rk13termux/BINA-BOT&Timeline)

---

<p align="center">
  <strong>Hecho con ❤️ para la comunidad crypto</strong><br>
  <sub>© 2025 BINA-BOT. Todos los derechos reservados.</sub>
</p> - Invictus Trader Pro

Professional Flutter cryptocurrency trading application with Binance integration, real-time analysis, and automation features.

## 🚀 Features

### Core Trading Features
- **Real-time Market Data**: Live price feeds via Binance WebSocket
- **Professional Charts**: Candlestick charts with technical indicators
- **Order Management**: Buy/sell orders with advanced options
- **Portfolio Tracking**: Real-time P&L analysis and performance metrics
- **Alert System**: Price alerts and smart notifications

### News & Analysis
- **Crypto News Aggregation**: Real-time news from CoinDesk, CoinTelegraph, and more
- **Search & Filtering**: Advanced search with category and source filters
- **Trending Topics**: Real-time trending cryptocurrency topics
- **Bookmarks**: Save and organize favorite articles
- **News Detail View**: In-app article reading with external browser support

### Advanced Features
- **Plugin System**: Custom trading strategies and indicators
- **AI Analysis**: TensorFlow Lite powered market analysis
- **Dark/Gold Theme**: Professional Binance-inspired UI
- **Multi-platform**: Android, iOS, Web, and Desktop support
- **Monetization**: AdMob integration with premium subscriptions

### Security & Storage
- **Secure Storage**: Flutter Secure Storage for API keys
- **Local Database**: Hive for offline data caching
- **Encrypted Communications**: All API calls secured

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Storage**: Hive + Flutter Secure Storage
- **HTTP Client**: http package
- **WebSocket**: web_socket_channel
- **Charts**: candlesticks, fl_chart
- **HTML Parsing**: html package for news scraping
- **ML**: tflite_flutter for AI analysis
- **Monetization**: google_mobile_ads, in_app_purchase

## � Screenshots

*Screenshots will be added after UI implementation*

## 🏗️ Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── api_manager.dart
│   ├── websocket_manager.dart
│   └── scraper_manager.dart
├── models/                 # Data models
│   ├── news_article.dart
│   ├── candle.dart
│   ├── trade.dart
│   └── user.dart
├── features/               # Feature modules
│   ├── dashboard/
│   ├── trading/
│   ├── alerts/
│   ├── news/
│   ├── plugins/
│   └── settings/
├── services/               # Business logic
│   ├── binance_service.dart
│   ├── scraping_service.dart
│   └── notification_service.dart
├── ui/                     # UI components
│   ├── theme/
│   └── widgets/
└── utils/                  # Utilities
    ├── logger.dart
    ├── constants.dart
    └── helpers.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Rk13termux/BINA-BOT.git
   cd BINA-BOT
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **Binance API Setup**
   - Create API keys in your Binance account
   - Add keys to secure storage (handled by the app)

2. **AdMob Setup** (Optional)
   - Configure AdMob app ID in `android/app/build.gradle`
   - Add AdMob unit IDs in the app

## 🔧 Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
flutter build windows --release  # Windows
flutter build macos --release    # macOS
flutter build linux --release    # Linux
```

## 📋 TODO / Roadmap

- [ ] Complete Binance API integration
- [ ] Implement advanced technical indicators
- [ ] Add backtesting functionality
- [ ] Create trading academy section
- [ ] Implement community features
- [ ] Add more cryptocurrency exchanges
- [ ] Implement copy trading features
- [ ] Add mobile notifications
- [ ] Create web dashboard
- [ ] Implement automated trading bots

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## � License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This application is for educational and informational purposes only. Cryptocurrency trading involves substantial risk and may result in significant losses. Always do your own research and never invest more than you can afford to lose.

## 📞 Support

For support, email: [your-email@example.com]
Or create an issue in this repository.

## 🎯 Features in Detail

### News System
- **Multi-source Aggregation**: Scrapes from multiple crypto news sources
- **Real-time Updates**: Auto-refresh news feeds
- **Advanced Search**: Search across titles, content, and tags
- **Category Filtering**: Filter by Bitcoin, Ethereum, DeFi, NFT, etc.
- **Source Filtering**: Filter by news source (CoinDesk, CoinTelegraph, etc.)
- **Trending Topics**: Automatically detected trending subjects
- **Bookmarking**: Save articles for later reading
- **Search History**: Keep track of previous searches
- **External Browser**: Open articles in external browser
- **Share Functionality**: Share articles with others

### Trading System
- **Real-time Data**: Live price feeds from Binance
- **Order Types**: Market, Limit, Stop-Loss orders
- **Portfolio Management**: Track holdings and performance
- **Risk Management**: Position sizing and risk controls
- **Technical Analysis**: Built-in indicators and chart tools

### Alert System
- **Price Alerts**: Set alerts for specific price levels
- **Technical Alerts**: Alerts based on indicator signals
- **News Alerts**: Notifications for breaking news
- **Portfolio Alerts**: Alerts for portfolio changes

---

**Built with ❤️ using Flutter**

## 💰 Monetization

### Free Tier
- Basic market data
- Limited news access
- Basic alerts (5 max)
- Ad-supported

### Premium Tier ($9.99/month)
- Real-time market data
- Unlimited news access
- Advanced alerts (25 max)
- No ads

### Pro Tier ($29.99/month)
- Professional trading tools
- Advanced analytics
- Plugin system
- AI-powered insights

## ⚠️ Disclaimer

Cryptocurrency trading involves substantial risk of loss. This software is for educational and informational purposes only.

---

**Made with ❤️ for the crypto trading community**r_pro

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
