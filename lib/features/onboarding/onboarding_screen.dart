import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/binance_service.dart';
import '../../services/groq_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _binanceApiKeyController = TextEditingController();
  final _binanceSecretKeyController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _error;

  Future<bool> _validateBinanceKeys(String apiKey, String secretKey) async {
    try {
      final binance = BinanceService();
      return await binance.setCredentials(apiKey: apiKey, secretKey: secretKey);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _validateGroqKey(String groqKey) async {
    try {
      final groq = GroqService();
      // Intentar una petición mínima para validar la clave
      await groq.getChatCompletion(messages: []);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveKeys() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    if (_formKey.currentState?.validate() ?? false) {
      final binanceApiKey = _binanceApiKeyController.text.trim();
      final binanceSecretKey = _binanceSecretKeyController.text.trim();
      final binanceValid =
          await _validateBinanceKeys(binanceApiKey, binanceSecretKey);
      if (!binanceValid) {
        setState(() {
          _error = 'Claves de Binance inválidas o sin permisos suficientes.';
          _isLoading = false;
        });
        return;
      }
      try {
        await _storage.write(key: 'binance_api_key', value: binanceApiKey);
        await _storage.write(
            key: 'binance_secret_key', value: binanceSecretKey);
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } catch (e) {
        setState(() {
          _error = 'Error guardando claves: $e';
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, color: Colors.blueAccent, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Bienvenido a QUANTIX AI CORE',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor, ingresa tus claves de Binance para comenzar.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _binanceApiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Binance API Key',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _binanceSecretKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Binance Secret Key',
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveKeys,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar y continuar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
