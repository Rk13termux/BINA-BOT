import 'package:flutter/material.dart';

class PluginCenterScreen extends StatefulWidget {
  const PluginCenterScreen({Key? key}) : super(key: key);

  @override
  State<PluginCenterScreen> createState() => _PluginCenterScreenState();
}

class _PluginCenterScreenState extends State<PluginCenterScreen> {
  List<PluginInfo> _plugins = [
    PluginInfo(
        name: 'Scalping Bot',
        description: 'Estrategia de scalping automatizada',
        enabled: true),
    PluginInfo(
        name: 'Swing Trading AI',
        description: 'IA para swing trading',
        enabled: false),
  ];

  void _togglePlugin(int index) {
    setState(() {
      _plugins[index] =
          _plugins[index].copyWith(enabled: !_plugins[index].enabled);
    });
  }

  void _addPlugin() async {
    // Aquí iría la lógica para cargar un plugin externo (JSON/.dart)
    // Por ahora, solo simula agregar uno nuevo
    setState(() {
      _plugins.add(PluginInfo(
          name: 'Nuevo Plugin',
          description: 'Plugin personalizado',
          enabled: false));
    });
  }

  void _configurePlugin(int index) {
    // Aquí iría la lógica para configurar el plugin visualmente
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configurar ${_plugins[index].name}'),
        content: const Text('Opciones de configuración próximamente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Center'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.amber),
            onPressed: _addPlugin,
            tooltip: 'Cargar nuevo plugin',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _plugins.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final plugin = _plugins[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: plugin.enabled ? Colors.amber : Colors.grey, width: 1),
            ),
            child: ListTile(
              leading: Icon(
                  plugin.enabled ? Icons.extension : Icons.extension_off,
                  color: plugin.enabled ? Colors.amber : Colors.grey),
              title: Text(plugin.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(plugin.description,
                  style: const TextStyle(color: Colors.white70)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                        plugin.enabled ? Icons.toggle_on : Icons.toggle_off,
                        color: plugin.enabled
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 32),
                    onPressed: () => _togglePlugin(index),
                    tooltip: plugin.enabled ? 'Desactivar' : 'Activar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.blueAccent),
                    onPressed: () => _configurePlugin(index),
                    tooltip: 'Configurar',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PluginInfo {
  final String name;
  final String description;
  final bool enabled;
  PluginInfo(
      {required this.name, required this.description, required this.enabled});

  PluginInfo copyWith({String? name, String? description, bool? enabled}) {
    return PluginInfo(
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }
}
