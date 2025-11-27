import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Español'; // idioma inicial

  @override
  Widget build(BuildContext context) {
    final List<String> settingsOptions = [
      'Sonido de pedido listo',
      'Idioma',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settingsOptions.length,
      itemBuilder: (context, index) {
        final option = settingsOptions[index];

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
