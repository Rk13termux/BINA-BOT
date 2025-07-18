import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../ui/theme/quantix_theme.dart';

/// 🔐 Onboarding Seguro de QUANTIX AI CORE
/// Pide las API keys de Binance y Groq al iniciar por primera vez
class QuantixOnboardingScreen extends StatefulWidget {
  const QuantixOnboardingScreen({super.key});

  @override
  State<QuantixOnboardingScreen> createState() => _QuantixOnboardingScreenState();
}

class _QuantixOnboardingScreenState extends State<QuantixOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Controllers para los inputs
  final TextEditingController _binanceApiController = TextEditingController();
  final TextEditingController _binanceSecretController = TextEditingController();
  final TextEditingController _groqApiController = TextEditingController();
  
  // Estado
  bool _isLoading = false;
  bool _apiKeysObscured = true;
  
  // Storage seguro
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _binanceApiController.dispose();
    _binanceSecretController.dispose();
    _groqApiController.dispose();
    super.dispose();
  }

  /// Validar y guardar las API keys
  Future<void> _validateAndSaveApiKeys() async {
    if (_binanceApiController.text.isEmpty ||
        _binanceSecretController.text.isEmpty ||
        _groqApiController.text.isEmpty) {
      _showErrorSnackBar('Por favor, completa todos los campos de API keys');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validar formato básico de las keys
      if (!_isValidBinanceApiKey(_binanceApiController.text)) {
        throw Exception('API Key de Binance inválida');
      }
      
      if (!_isValidGroqApiKey(_groqApiController.text)) {
        throw Exception('API Key de Groq inválida');
      }

      // Guardar en storage seguro
      await _secureStorage.write(
        key: 'binance_api_key',
        value: _binanceApiController.text.trim(),
      );
      await _secureStorage.write(
        key: 'binance_secret_key',
        value: _binanceSecretController.text.trim(),
      );
      await _secureStorage.write(
        key: 'groq_api_key',
        value: _groqApiController.text.trim(),
      );
      
      // Marcar onboarding como completado
      await _secureStorage.write(key: 'onboarding_completed', value: 'true');
      
      // TODO: Validar conexión real con las APIs
      await _testApiConnections();
      
      // Navegar al dashboard principal
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
      
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Validar formato de API key de Binance
  bool _isValidBinanceApiKey(String key) {
    return key.length >= 32 && key.isNotEmpty;
  }

  /// Validar formato de API key de Groq
  bool _isValidGroqApiKey(String key) {
    return key.startsWith('gsk_') && key.length > 50;
  }

  /// Probar conexiones con las APIs
  Future<void> _testApiConnections() async {
    // TODO: Implementar pruebas reales de conexión
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Mostrar error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: QuantixTheme.bearishRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              QuantixTheme.primaryBlack,
              QuantixTheme.secondaryBlack,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: PageView(
              controller: _pageController,
              children: [
                _buildWelcomePage(),
                _buildSecurityPage(),
                _buildApiSetupPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Página de Bienvenida
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo y Título
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: QuantixTheme.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: QuantixTheme.primaryGold.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_graph,
              size: 60,
              color: QuantixTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 40),
          
          // Título principal
          Text(
            'QUANTIX AI CORE',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Eslogan
          Text(
            'Piensa como fondo, opera como elite.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: QuantixTheme.electricBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Características
          _buildFeatureList(),
          
          const Spacer(),
          
          // Botón continuar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('COMENZAR CONFIGURACIÓN'),
            ),
          ),
        ],
      ),
    );
  }

  /// Página de Seguridad
  Widget _buildSecurityPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header
          _buildHeader('Seguridad Elite', 'shield'),
          
          const SizedBox(height: 40),
          
          // Información de seguridad
          _buildSecurityInfo(),
          
          const Spacer(),
          
          // Botones
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('ATRÁS'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('CONFIGURAR APIS'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Página de configuración de APIs
  Widget _buildApiSetupPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header
          _buildHeader('Configuración de APIs', 'api'),
          
          const SizedBox(height: 40),
          
          // Formulario de APIs
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Binance API Section
                  _buildApiSection(
                    'Binance API',
                    'Conecta con tu cuenta de Binance para trading en tiempo real',
                    [
                      _buildApiInput(
                        'API Key',
                        _binanceApiController,
                        'Pega tu API Key de Binance aquí',
                        Icons.key,
                      ),
                      const SizedBox(height: 16),
                      _buildApiInput(
                        'Secret Key',
                        _binanceSecretController,
                        'Pega tu Secret Key de Binance aquí',
                        Icons.lock,
                        isSecret: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Groq API Section
                  _buildApiSection(
                    'Groq AI',
                    'Análisis inteligente con Llama 3.3 70B - Completamente GRATIS',
                    [
                      _buildApiInput(
                        'Groq API Key',
                        _groqApiController,
                        'Pega tu API Key de Groq aquí (gsk_...)',
                        Icons.psychology,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botones finales
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('ATRÁS'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndSaveApiKeys,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ACTIVAR QUANTIX'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget de header con ícono
  Widget _buildHeader(String title, String iconName) {
    IconData icon;
    switch (iconName) {
      case 'shield':
        icon = Icons.security;
        break;
      case 'api':
        icon = Icons.api;
        break;
      default:
        icon = Icons.star;
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: QuantixTheme.blueGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: QuantixTheme.primaryBlack),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Lista de características
  Widget _buildFeatureList() {
    final features = [
      'Trading inteligente con IA',
      'Análisis técnico avanzado',
      'Noticias en tiempo real',
      'Sistema de alertas profesional',
      'Seguridad de nivel institucional',
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: QuantixTheme.primaryGold,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  /// Información de seguridad
  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        children: [
          const Icon(
            Icons.verified_user,
            color: QuantixTheme.primaryGold,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Máxima Seguridad',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tus API keys se cifran localmente usando Flutter Secure Storage. '
            'Nunca se envían a servidores externos ni se almacenan en texto plano.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSecurityFeature(Icons.lock, 'Cifrado\nLocal'),
              _buildSecurityFeature(Icons.vpn_key, 'Claves\nSeguras'),
              _buildSecurityFeature(Icons.shield, 'Nivel\nBanco'),
            ],
          ),
        ],
      ),
    );
  }

  /// Característica de seguridad
  Widget _buildSecurityFeature(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: QuantixTheme.electricBlue, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Sección de API
  Widget _buildApiSection(String title, String description, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  /// Input para API key
  Widget _buildApiInput(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isSecret = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isSecret && _apiKeysObscured,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: QuantixTheme.primaryGold),
        suffixIcon: isSecret
            ? IconButton(
                icon: Icon(
                  _apiKeysObscured ? Icons.visibility : Icons.visibility_off,
                  color: QuantixTheme.neutralGray,
                ),
                onPressed: () => setState(() => _apiKeysObscured = !_apiKeysObscured),
              )
            : null,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
