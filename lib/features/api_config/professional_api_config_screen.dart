import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/app_colors.dart';
import '../../services/binance_service.dart';
import '../../services/ai_service_professional.dart' as ai_professional;
import '../../utils/logger.dart';

/// Pantalla profesional de configuración de APIs sin keys preconfiguradas
class ApiConfigurationScreen extends StatefulWidget {
  const ApiConfigurationScreen({super.key});

  @override
  State<ApiConfigurationScreen> createState() => _ApiConfigurationScreenState();
}

class _ApiConfigurationScreenState extends State<ApiConfigurationScreen>
    with TickerProviderStateMixin {
  static final AppLogger _logger = AppLogger();
  
  late TabController _tabController;
  late AnimationController _loadingController;
  
  // Controladores de texto
  final _binanceApiKeyController = TextEditingController();
  final _binanceSecretController = TextEditingController();
  final _groqApiKeyController = TextEditingController();
  
  // Estados de configuración
  bool _isTestingBinance = false;
  bool _binanceConfigured = false;
  bool _isTestNet = false;
  bool _obscureBinanceSecret = true;
  bool _isTestingGroq = false;
  bool _groqConfigured = false;
  bool _obscureGroqKey = true;
  
  String? _binanceTestResult;
  bool _binanceTestSuccess = false;
  String? _groqTestResult;
  bool _groqTestSuccess = false;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _checkExistingConfiguration();
  }

  void _checkExistingConfiguration() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar configuraciones existentes
      final binanceService = context.read<BinanceService>();
      final aiService = context.read<ai_professional.AIService>();
      
      setState(() {
        _binanceConfigured = binanceService.isAuthenticated;
        _groqConfigured = aiService.isAvailable;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.backgroundSecondary,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Indicador de progreso
              _buildProgressIndicator(),
              
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.goldPrimary,
                labelColor: AppColors.goldPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.currency_bitcoin),
                    text: 'Binance API',
                  ),
                  Tab(
                    icon: Icon(Icons.psychology),
                    text: 'Groq AI',
                  ),
                ],
              ),
              
              // Contenido de las tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBinanceConfigTab(),
                    _buildGroqConfigTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.goldPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuración de APIs',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure sus credenciales para acceso completo',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de seguridad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.green,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'SEGURO',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = ((_binanceConfigured ? 0.5 : 0.0) + (_groqConfigured ? 0.5 : 0.0));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Progreso de Configuración',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBinanceConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de Binance
          _buildInfoCard(
            'Binance API',
            'Conecte su cuenta de Binance para trading en tiempo real y acceso a datos de mercado.',
            Icons.currency_bitcoin,
            Colors.orange,
          ),
          
          const SizedBox(height: 24),
          
          // Instrucciones paso a paso
          _buildInstructionsCard('Binance'),
          
          const SizedBox(height: 24),
          
          // Formulario Binance
          _buildBinanceForm(),
          
          const SizedBox(height: 24),
          
          // Resultado de prueba
          if (_binanceTestResult != null)
            _buildTestResult(_binanceTestResult!, _binanceTestSuccess),
        ],
      ),
    );
  }

  

  Widget _buildInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(String apiType) {
    final instructions = apiType == 'Binance' 
        ? [
            '1. Vaya a Binance.com → Account → API Management',
            '2. Cree una nueva API Key con nombre "InvictusTrader"',
            '3. Habilite permisos: "Spot & Margin Trading" + "Futures"',
            '4. Copie y pegue ambas keys en los campos siguientes',
            '5. Para mayor seguridad, use TestNet para pruebas',
            '6. Nunca comparta sus API Keys con terceros',
          ] : [
            '1. Vaya a console.groq.com',
            '2. Cree una cuenta o inicie sesión',
            '3. Navegue a "API Keys" en el panel',
            '4. Genere una nueva API Key',
            '5. Copie inmediatamente (no se mostrará de nuevo)',
            '6. Mantenga su key segura y privada',
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instrucciones Paso a Paso',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...instructions.map((instruction) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              instruction,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildGroqConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de Groq AI
          _buildInfoCard(
            'Groq AI Assistant',
            'Configure su API key de Groq para análisis inteligente con IA y asistente conversacional.',
            Icons.psychology,
            Colors.purple,
          ),
          
          const SizedBox(height: 24),
          
          // Instrucciones paso a paso
          _buildInstructionsCard('Groq'),
          
          const SizedBox(height: 24),
          
          // Formulario Groq
          _buildGroqForm(),
          
          const SizedBox(height: 24),
          
          // Resultado de prueba
          if (_groqTestResult != null)
            _buildTestResult(_groqTestResult!, _groqTestSuccess),
        ],
      ),
    );
  }

  Widget _buildGroqForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.goldPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Configuración de Groq AI',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // API Key Field
          _buildTextField(
            controller: _groqApiKeyController,
            label: 'Groq API Key',
            hint: 'Ingrese su Groq API Key',
            icon: Icons.vpn_key,
            obscureText: _obscureGroqKey,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureGroqKey ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureGroqKey = !_obscureGroqKey;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Test Connection Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTestingGroq ? null : _testGroqConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isTestingGroq 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.psychology),
              label: Text(
                _isTestingGroq ? 'Probando IA...' : 'Probar Conexión IA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBinanceForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: AppColors.goldPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Configuración de Binance API',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Switch TestNet
          Row(
            children: [
              Switch(
                value: _isTestNet,
                onChanged: (value) {
                  setState(() {
                    _isTestNet = value;
                  });
                },
                activeColor: AppColors.goldPrimary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usar TestNet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Recomendado para pruebas iniciales',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // API Key Field
          _buildTextField(
            controller: _binanceApiKeyController,
            label: 'API Key',
            hint: 'Ingrese su Binance API Key',
            icon: Icons.vpn_key,
          ),
          
          const SizedBox(height: 16),
          
          // Secret Key Field
          _buildTextField(
            controller: _binanceSecretController,
            label: 'Secret Key',
            hint: 'Ingrese su Binance Secret Key',
            icon: Icons.security,
            obscureText: _obscureBinanceSecret,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureBinanceSecret ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureBinanceSecret = !_obscureBinanceSecret;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Test Connection Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTestingBinance ? null : _testBinanceConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isTestingBinance 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Icon(Icons.link),
              label: Text(
                _isTestingBinance ? 'Probando Conexión...' : 'Probar Conexión',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de testing
  Future<void> _testBinanceConnection() async {
    if (_binanceApiKeyController.text.trim().isEmpty || 
        _binanceSecretController.text.trim().isEmpty) {
      setState(() {
        _binanceTestResult = 'Por favor complete ambos campos de Binance';
        _binanceTestSuccess = false;
      });
      return;
    }

    setState(() {
      _isTestingBinance = true;
      _binanceTestResult = null;
    });

    try {
      final binanceService = context.read<BinanceService>();
      
      final success = await binanceService.setCredentials(
        apiKey: _binanceApiKeyController.text.trim(),
        secretKey: _binanceSecretController.text.trim(),
        isTestNet: _isTestNet,
      );

      if (success) {
        final price = await binanceService.getPrice('BTCUSDT');
        setState(() {
          _binanceTestResult = '✅ Conexión exitosa! Precio BTC: \$${price.toStringAsFixed(2)}';
          _binanceTestSuccess = true;
          _binanceConfigured = true;
        });
        _logger.info('Binance API configured successfully');
      } else {
        setState(() {
          _binanceTestResult = '❌ Error: ${binanceService.lastError ?? "Credenciales inválidas"}';
          _binanceTestSuccess = false;
          _binanceConfigured = false;
        });
      }
    } catch (e) {
      setState(() {
        _binanceTestResult = '❌ Error de conexión: $e';
        _binanceTestSuccess = false;
        _binanceConfigured = false;
      });
      _logger.error('Binance API test failed: $e');
    } finally {
      setState(() {
        _isTestingBinance = false;
      });
    }
  }

  Future<void> _testGroqConnection() async {
    if (_groqApiKeyController.text.trim().isEmpty) {
      setState(() {
        _groqTestResult = 'Por favor ingrese su Groq API Key';
        _groqTestSuccess = false;
      });
      return;
    }

    setState(() {
      _isTestingGroq = true;
      _groqTestResult = null;
    });

    try {
      final aiService = context.read<ai_professional.AIService>();
      
      final success = await aiService.setGroqApiKey(_groqApiKeyController.text.trim());

      if (success) {
        setState(() {
          _groqTestResult = '✅ IA conectada! Modelo: Mistral 7B disponible';
          _groqTestSuccess = true;
          _groqConfigured = true;
        });
        _logger.info('Groq AI configured successfully');
      } else {
        setState(() {
          _groqTestResult = '❌ Error: API Key inválida o sin permisos';
          _groqTestSuccess = false;
          _groqConfigured = false;
        });
      }
    } catch (e) {
      setState(() {
        _groqTestResult = '❌ Error de conexión con Groq: $e';
        _groqTestSuccess = false;
        _groqConfigured = false;
      });
      _logger.error('Groq API test failed: $e');
    } finally {
      setState(() {
        _isTestingGroq = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
            prefixIcon: Icon(icon, color: AppColors.goldPrimary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.goldPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestResult(String result, bool success) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success 
              ? Colors.green.withOpacity(0.3) 
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result,
              style: TextStyle(
                color: success ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loadingController.dispose();
    _binanceApiKeyController.dispose();
    _binanceSecretController.dispose();
    _groqApiKeyController.dispose();
    super.dispose();
  }
}
