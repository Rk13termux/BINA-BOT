import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _licenseStatus = 'Activa';
  String _subscriptionType = 'Pro';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));
  bool _isPaying = false;

  void _payWithUSDT() async {
    setState(() {
      _isPaying = true;
    });
    // Aquí iría la lógica real de pago y validación por Telegram Bot
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isPaying = false;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pago recibido'),
        content: const Text(
            'Tu suscripción será activada tras la validación automática.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Licencia & Suscripción'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_licenseStatus == 'Activa' ? Icons.verified : Icons.error,
                    color: _licenseStatus == 'Activa'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    size: 32),
                const SizedBox(width: 12),
                Text('Licencia: $_licenseStatus',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.workspace_premium,
                    color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text('Tipo: $_subscriptionType',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.blueAccent, size: 24),
                const SizedBox(width: 8),
                Text(
                    'Expira: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            const Text('Paga tu suscripción con USDT (Binance):',
                style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('1. Envía 5 USDT (mensual) o 49 USDT (anual) a:',
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  SelectableText('TU_DIRECCION_USDT_AQUI',
                      style: TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('2. Envía el comprobante al Bot de Telegram:',
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  SelectableText('@QuantixLicBot',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      '3. Tu licencia se activará automáticamente tras la validación.',
                      style: TextStyle(color: Colors.greenAccent)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _isPaying ? null : _payWithUSDT,
                icon: const Icon(Icons.payment, color: Colors.white),
                label: _isPaying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Pagar con USDT',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
