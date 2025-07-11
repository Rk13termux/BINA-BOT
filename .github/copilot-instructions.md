<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Invictus Trader Pro - Copilot Instructions

This is a professional Flutter trading application for cryptocurrency trading with Binance integration.

## Project Overview
- **App Name**: Invictus Trader Pro
- **Platform**: Flutter (Multi-platform: Android, iOS, Web, Desktop)
- **Purpose**: Professional cryptocurrency trading platform with real-time analysis and automation
- **Architecture**: Clean Architecture with Provider for state management

## Key Technologies
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Storage**: Hive + Flutter Secure Storage
- **HTTP Client**: http package
- **WebSocket**: web_socket_channel
- **Charts**: candlesticks, fl_chart
- **HTML Parsing**: html package for news scraping
- **ML**: tflite_flutter for AI analysis
- **Monetization**: google_mobile_ads, in_app_purchase

## Code Style Guidelines
1. **Naming Conventions**:
   - Classes: PascalCase (e.g., `ApiManager`, `DashboardController`)
   - Variables/Functions: camelCase (e.g., `getCurrentPrice`, `userBalance`)
   - Constants: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)
   - Files: snake_case (e.g., `api_manager.dart`, `dashboard_screen.dart`)

2. **Architecture**:
   - `/core`: Core functionality (API, WebSocket, Storage, etc.)
   - `/models`: Data models and entities
   - `/features`: Feature-based modules (dashboard, trading, alerts, etc.)
   - `/services`: Business logic and external integrations
   - `/ui`: UI components (widgets, theme)
   - `/utils`: Utilities and helpers

3. **Theme**: Dark theme with gold accents (similar to Binance Pro)
   - Primary Dark: #1A1A1A
   - Gold Primary: #FFD700
   - Bullish Green: #00FF88
   - Bearish Red: #FF4444

## Important Implementation Notes
1. **Security**: Always use Flutter Secure Storage for API keys and sensitive data
2. **Error Handling**: Implement comprehensive try-catch blocks with logging
3. **WebSocket**: Implement reconnection logic for real-time data
4. **Scraping**: Use proper User-Agent headers and respect rate limits
5. **Plugin System**: Use dart_eval for safe plugin execution
6. **Trading**: Implement proper validation and confirmation for all trades
7. **Monetization**: Free tier with ads, Premium tiers with advanced features

## Key Features to Implement
- Real-time price monitoring via Binance WebSocket
- Professional candlestick charts with technical indicators
- News scraping from multiple crypto sources (CoinDesk, CoinTelegraph, etc.)
- Plugin system for custom trading strategies
- Alert system with notifications
- Portfolio tracking and P&L analysis
- AI-powered market analysis with TensorFlow Lite

## API Integration
- **Binance API**: Use for market data, account info, and trading
- **WebSocket Streams**: Real-time price feeds and order book data
- **News Sources**: Web scraping without external APIs

## State Management
- Use Provider for state management
- Implement proper lifecycle management
- Cache data locally with Hive for offline capability

## Testing Strategy
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for API interactions
- Mock external dependencies

When generating code:
1. Follow the established architecture patterns
2. Include proper error handling and logging
3. Use the defined color scheme and theme
4. Implement responsive design for multiple screen sizes
5. Add comprehensive documentation
6. Consider performance implications for real-time data
7. Implement proper loading states and error messages
8. Use the AppLogger for consistent logging
9. Follow the security best practices for sensitive data
10. Implement proper validation for user inputs
