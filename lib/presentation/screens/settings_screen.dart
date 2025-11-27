import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/beer_counter/beer_counter_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/beer_counter/beer_counter_event.dart';
import 'package:proyecto_homero/presentation/blocs/beer_counter/beer_counter_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Español'; // idioma inicial

  @override
  Widget build(BuildContext context) {
    final List<String> settingsOptions = [
      'Sonido WOOHOO!',
      'Idioma',
    ];

    return BlocBuilder<BeerCounterBloc, BeerCounterState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: settingsOptions.length,
          itemBuilder: (context, index) {
            final option = settingsOptions[index];

            if (option == 'Sonido WOOHOO!') {
              return Card(
                color: Colors.yellow[100],
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: SwitchListTile(
                  title: Text(
                    option,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: state.isWoohooSoundEnabled,
                  onChanged: (bool value) {
                    context.read<BeerCounterBloc>().add(WoohooSoundToggled());
                  },
                  secondary: Icon(state.isWoohooSoundEnabled ? Icons.volume_up : Icons.volume_off, color: Colors.yellow[800]),
                  activeColor: Colors.yellow[800],
                ),
              );
            }

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
                  onTap: () => _showLanguageMenu(context),
                ),
              );
            }
            return const SizedBox.shrink(); // No debería llegar aquí
          },
        );
      },
    );
  }

  void _showLanguageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final languages = ['Americano', 'El de Lisa'];
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
