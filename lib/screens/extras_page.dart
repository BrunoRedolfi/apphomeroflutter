import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

// Extras con el switch y contador de cervezas
class ExtrasPage extends StatefulWidget {
  const ExtrasPage({super.key});

  @override
  State<ExtrasPage> createState() => _ExtrasPageState();
}

class _ExtrasPageState extends State<ExtrasPage> {
  bool _beerCounterActive = false;
  int _beerCount = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Extras de Homero 🍩🍺',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),

        // Switch estilo "botón" adaptativo
        Card(
          color: Colors.yellow[100],
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.yellow[800]),
            title: Text(
              'Activar contador de cervezas 🍺',
              style: TextStyle(
                fontSize: Platform.isIOS ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Switch.adaptive(
              value: _beerCounterActive,
              onChanged: (value) {
                setState(() => _beerCounterActive = value);
              },
            ),
          ),
        ),

        SizedBox(height: 20),

        if (_beerCounterActive) ...[
          Text(
            'Cervezas consumidas hoy: $_beerCount',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
            ),
            icon: Icon(Icons.add),
            label: Text("Agregar una Duff"),
            onPressed: () {
              setState(() => _beerCount++);
            },
          ),

          SizedBox(height: 20),
        ],
        Card(
          color: Colors.yellow[100],
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.settings, color: Colors.yellow[800]),
            title: Text(
              'Descuentos especiales',
              style: TextStyle(
                fontSize: Platform.isIOS ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
