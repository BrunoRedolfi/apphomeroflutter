import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_homero/presentation/services/notification_service.dart';
import 'package:proyecto_homero/presentation/services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Español'; // idioma inicial
  bool _waterReminderActive = false; // Estado para el recordatorio
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isActive = await _settingsService.getWaterReminder();
    setState(() {
      _waterReminderActive = isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> settingsOptions = [
      'Notificaciones',
      'Sonido de pedido listo',
      'Recordatorio de beber agua',
      'Idioma',
      'Tema claro/oscuro',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settingsOptions.length,
      itemBuilder: (context, index) {
        final option = settingsOptions[index];

        // --- NUEVO: Caso para el recordatorio de agua ---
        if (option == 'Recordatorio de beber agua') {
          return Card(
            color: Colors.yellow[100],
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.opacity, color: Colors.blue[400]),
              title: Text(
                option,
                style: TextStyle(
                  fontSize: Platform.isIOS ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Switch.adaptive(
                value: _waterReminderActive,
                onChanged: _onWaterReminderChanged,
                activeColor: Colors.blue,
              ),
            ),
          );
        }

        // Si es el ítem "Idioma", hacemos un ListTile especial
        if (option == 'Idioma') {
          return Card(
            color: Colors.yellow[100],
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.language, color: Colors.yellow[800]),
              title: Text(
                '$option: $_selectedLanguage',
                style: TextStyle(
                  fontSize: Platform.isIOS ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _showLanguageMenu(context), // abre el menú
            ),
          );
        }

        // ListTile normal para otros ítems
        return Card(
          color: Colors.yellow[100],
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.yellow[800]),
            title: Text(
              option,
              style: TextStyle(
                fontSize: Platform.isIOS ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Platform.isIOS
                ? CupertinoSwitch(value: false, onChanged: (val) {}, activeColor: Colors.yellow[800])
                : Switch(value: false, onChanged: (val) {}, activeColor: Colors.yellow[800]),
          ),
        );
      },
    );
  }

  // --- NUEVO: Método para manejar el cambio del switch ---
  void _onWaterReminderChanged(bool value) {
    setState(() {
      _waterReminderActive = value;
    });
    if (value) {
      // Si se activa, programamos la notificación
      _notificationService.scheduleHourlyWaterReminder();
      _settingsService.setWaterReminder(true);
    } else {
      // Si se desactiva, cancelamos todas las notificaciones programadas
      _notificationService.cancelAllNotifications();
      _settingsService.setWaterReminder(false);
    }
  }


  void _showLanguageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final languages = ['Español', 'Inglés', 'El de Lisa'];
        return ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final lang = languages[index];
            return ListTile(
              title: Text(lang),
              onTap: () {
                setState(() {
                  _selectedLanguage = lang;
                });
                Navigator.pop(context); // cierra el bottom sheet
              },
            );
          },
        );
      },
    );
  }
}
