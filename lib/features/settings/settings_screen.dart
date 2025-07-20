import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  String _language = 'es';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final darkMode = await LocalStorageService.loadDarkMode();
    final language = await LocalStorageService.loadLanguage();
    final notifications = await LocalStorageService.loadNotificationsEnabled();
    setState(() {
      _darkMode = darkMode;
      _language = language;
      _notificationsEnabled = notifications;
    });
  }

  void _toggleDarkMode(bool value) async {
    setState(() {
      _darkMode = value;
    });
    await LocalStorageService.saveDarkMode(value);
    // Aquí iría la lógica para aplicar el tema globalmente
  }

  void _changeLanguage(String? value) async {
    if (value != null) {
      setState(() {
        _language = value;
      });
      await LocalStorageService.saveLanguage(value);
      // Aquí iría la lógica para cambiar el idioma globalmente
    }
  }

  void _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await LocalStorageService.saveNotificationsEnabled(value);
    // Aquí iría la lógica para activar/desactivar notificaciones
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Preferencias Generales',
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _darkMode,
            onChanged: _toggleDarkMode,
            title: const Text('Modo oscuro',
                style: TextStyle(color: Colors.white)),
            secondary: const Icon(Icons.dark_mode, color: Colors.amber),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blueAccent),
            title: const Text('Idioma', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<String>(
              value: _language,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: _changeLanguage,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            title: const Text('Notificaciones',
                style: TextStyle(color: Colors.white)),
            secondary:
                const Icon(Icons.notifications_active, color: Colors.amber),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          const Text('Sobre QUANTIX AI CORE',
              style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
            title: const Text('Versión', style: TextStyle(color: Colors.white)),
            subtitle:
                const Text('1.0.0', style: TextStyle(color: Colors.white70)),
          ),
          ListTile(
            leading: const Icon(Icons.verified, color: Colors.greenAccent),
            title:
                const Text('Licencia', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Uso exclusivo para miembros Quantix',
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
