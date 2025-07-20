import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [
    NotificationItem(
        title: 'Señal de compra BTC/USDT',
        type: 'signal',
        time: '09:15',
        important: true),
    NotificationItem(
        title: 'Cruce EMA 20/50 en ETH',
        type: 'indicator',
        time: '08:50',
        important: false),
    NotificationItem(
        title: 'AI: Riesgo de volatilidad en DOGE',
        type: 'ai',
        time: '08:30',
        important: true),
  ];
  bool _nightMode = false;

  void _toggleNightMode() {
    setState(() {
      _nightMode = !_nightMode;
    });
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'signal':
        return Colors.greenAccent;
      case 'indicator':
        return Colors.blueAccent;
      case 'ai':
        return Colors.amber;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_nightMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: Colors.amber),
            onPressed: _toggleNightMode,
            tooltip: _nightMode
                ? 'Modo nocturno activado'
                : 'Modo nocturno desactivado',
          ),
        ],
      ),
      backgroundColor: _nightMode ? Colors.black : Colors.blueGrey[900],
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: notif.important
                  ? Colors.amber.withOpacity(0.1)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _typeColor(notif.type), width: 2),
            ),
            child: ListTile(
              leading: Icon(
                notif.type == 'signal'
                    ? Icons.campaign
                    : notif.type == 'indicator'
                        ? Icons.bar_chart
                        : Icons.smart_toy,
                color: _typeColor(notif.type),
              ),
              title: Text(notif.title,
                  style: TextStyle(
                      color: notif.important ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.bold)),
              subtitle: Text('Hora: ${notif.time}',
                  style: const TextStyle(color: Colors.white70)),
              trailing: notif.important
                  ? const Icon(Icons.priority_high, color: Colors.redAccent)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String type;
  final String time;
  final bool important;
  NotificationItem(
      {required this.title,
      required this.type,
      required this.time,
      required this.important});
}
