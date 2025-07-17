import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/binance_service.dart';
import '../../ui/theme/app_theme.dart';
import '../../utils/logger.dart';

/// Pantalla de configuración profesional de APIs
class ApiConfigScreen extends StatefulWidget {
  const ApiConfigScreen({super.key});

  @override
  State<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen>
    with TickerProviderStateMixin {
  
  static final AppLogger _logger = AppLogger();
  
  // Controladores de texto
  final TextEditingController _binanceApiKeyController = TextEditingController();
  final TextEditingController _binanceSecretController = TextEditingController();
  
  // Controladores de animación
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  
  // Estado de la pantalla
  bool _isTestingBinance = false;
  bool _isSaving = false;
  bool _obscureBinanceSecret = true;
  bool _isTestNet = false;
  
  // Resultados de tests
  String? _binanceTestResult;
  bool _binanceTestSuccess = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadStoredCredentials();
  }

  void _initializeAnimations() {
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadStoredCredentials() {
    // Las credenciales se cargan automáticamente por los servicios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final binanceService = context.read<BinanceService>();
      
      // Indicar si ya están configurados (sin mostrar las keys)
      if (binanceService.isAuthenticated) {
        _binanceApiKeyController.text = '••••••••••••••••';
        _binanceSecretController.text = '••••••••••••••••';
        _binanceTestResult = 'Configurado anteriormente';
        _binanceTestSuccess = true;
      }
      
      setState(() {});
    });
  }

  @override
  void dispose() {
    _binanceApiKeyController.dispose();
    _binanceSecretController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildBinanceSection(),
            
            const SizedBox(height: 30),
            _buildTestResultsSection(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'CONFIGURACIÓN DE APIs',
        style: TextStyle(
          color: Color(0xFFFFD700),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.2),
            const Color(0xFFFFD700).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: const Color(0xFFFFD700),
                size: 32,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Configuración Segura de APIs',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Configure sus API Keys de forma segura para habilitar todas las funcionalidades de Invictus Trader Pro.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildSecurityNote(),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_rounded,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sus API Keys se almacenan de forma segura usando encriptación local.',
              style: TextStyle(
                color: const Color(0xFF4CAF50),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBinanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.currency_bitcoin,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Binance API',
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Consumer<BinanceService>(
                builder: (context, service, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: service.isAuthenticated 
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                          : const Color(0xFFFF5722).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.isAuthenticated ? 'CONECTADO' : 'DESCONECTADO',
                      style: TextStyle(
                        color: service.isAuthenticated 
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF5722),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // TestNet Toggle
          Row(
            children: [
              Switch(
                value: _isTestNet,
                onChanged: (value) {
                  setState(() {
                    _isTestNet = value;
                  });
                },
                activeColor: const Color(0xFFFFD700),
              ),
              const SizedBox(width: 12),
              Text(
                'Usar TestNet (Recomendado para pruebas)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // API Key Field
          _buildTextField(
            controller: _binanceApiKeyController,
            label: 'API Key',
            hint: 'Ingrese su Binance API Key',
            obscureText: false,
            prefixIcon: Icons.key,
          ),
          
          const SizedBox(height: 16),
          
          // Secret Key Field
          _buildTextField(
            controller: _binanceSecretController,
            label: 'Secret Key',
            hint: 'Ingrese su Binance Secret Key',
            obscureText: _obscureBinanceSecret,
            prefixIcon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureBinanceSecret ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFFFFD700),
              ),
              onPressed: () {
                setState(() {
                  _obscureBinanceSecret = !_obscureBinanceSecret;
                });
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Test Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTestingBinance ? null : _testBinanceConnection,
              icon: _isTestingBinance 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(_isTestingBinance ? 'PROBANDO...' : 'PROBAR CONEXIÓN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Instrucciones
          const SizedBox(height: 16),
          _buildInstructions('Binance'),
        ],
      ),
    );
  }

  

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFFFFD700),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFFD700),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(String apiType) {
    final instructions = apiType == 'Binance' 
        ? [
            '1. Vaya a Binance.com → Account → API Management',
            '2. Cree una nueva API Key',
            '3. Habilite permisos de "Spot & Margin Trading"',
            '4. Copie y pegue las keys aquí',
            '5. Para seguridad, use TestNet primero',
          ]
        : [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instrucciones:',
            style: TextStyle(
              color: const Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...instructions.map((instruction) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              instruction,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTestResultsSection() {
    if (_binanceTestResult == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESULTADOS DE PRUEBAS',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_binanceTestResult != null)
            _buildTestResult(
              'Binance API',
              _binanceTestResult!,
              _binanceTestSuccess,
              Icons.currency_bitcoin,
            ),
          
          
        ],
      ),
    );
  }

  Widget _buildTestResult(String title, String result, bool success, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success 
            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
            : const Color(0xFFFF5722).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: success 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : const Color(0xFFFF5722).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
            size: 20,
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: success ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: success ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result,
              style: TextStyle(
                color: success ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Guardar configuración
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveConfiguration,
            icon: _isSaving 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'GUARDANDO...' : 'GUARDAR CONFIGURACIÓN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Limpiar credenciales
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _clearCredentials,
            icon: const Icon(Icons.delete_outline),
            label: const Text('LIMPIAR CREDENCIALES'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF5722),
              side: const BorderSide(color: Color(0xFFFF5722)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // === MÉTODOS DE FUNCIONALIDAD ===

  Future<void> _testBinanceConnection() async {
    if (_binanceApiKeyController.text.isEmpty || 
        _binanceSecretController.text.isEmpty) {
      _showSnackBar('Por favor complete ambos campos de Binance', false);
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
        // Probar obteniendo un precio
        final price = await binanceService.getPrice('BTCUSDT');
        setState(() {
          _binanceTestResult = 'Conexión exitosa. Precio BTC: \$${price.toStringAsFixed(2)}';
          _binanceTestSuccess = true;
        });
        _showSnackBar('✅ Binance API conectado exitosamente', true);
      } else {
        setState(() {
          _binanceTestResult = 'Error: ${binanceService.lastError ?? "Credenciales inválidas"}';
          _binanceTestSuccess = false;
        });
        _showSnackBar('❌ Error conectando con Binance API', false);
      }
    } catch (e) {
      setState(() {
        _binanceTestResult = 'Error: $e';
        _binanceTestSuccess = false;
      });
      _showSnackBar('❌ Error: $e', false);
    } finally {
      setState(() {
        _isTestingBinance = false;
      });
    }
  }

  

  Future<void> _saveConfiguration() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final binanceService = context.read<BinanceService>();
      
      // Guardar credenciales de Binance si están configuradas
      if (_binanceApiKeyController.text.isNotEmpty && 
          _binanceSecretController.text.isNotEmpty) {
        final binanceSuccess = await binanceService.setCredentials(
          apiKey: _binanceApiKeyController.text.trim(),
          secretKey: _binanceSecretController.text.trim(),
          isTestNet: _isTestNet,
        );
        
        if (!binanceSuccess) {
          throw Exception('Error al guardar credenciales de Binance');
        }
      }
      
      
      
      await Future.delayed(const Duration(milliseconds: 500)); // UX
      
      _showSnackBar('✅ Configuración guardada exitosamente', true);
      
      // Volver a la pantalla anterior
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
      
    } catch (e) {
      _showSnackBar('❌ Error guardando configuración: $e', false);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _clearCredentials() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Confirmar',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: const Text(
          '¿Está seguro de que desea eliminar todas las credenciales almacenadas?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFFF5722)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final binanceService = context.read<BinanceService>();
        
        await binanceService.clearCredentials();
        
        _showSnackBar('✅ Credenciales eliminadas', true);
      } catch (e) {
        _showSnackBar('❌ Error eliminando credenciales: $e', false);
      }
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isSuccess 
            ? const Color(0xFF4CAF50) 
            : const Color(0xFFFF5722),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
