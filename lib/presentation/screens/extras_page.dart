import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
// para agregar map_screen al proyecto
import 'package:proyecto_homero/presentation/screens/map_screen.dart';
import '../blocs/beer_counter/beer_counter_bloc.dart';
import '../blocs/beer_counter/beer_counter_event.dart';
import '../blocs/beer_counter/beer_counter_state.dart';

// Extras con el switch y contador de cervezas
class ExtrasPage extends StatelessWidget {
  const ExtrasPage({super.key});

  // --- NUEVA FUNCIÓN PARA MOSTRAR LA ALERTA ---
  void _mostrarAlertaHomero(BuildContext context) {
    //Reproduce el sonido justo antes de mostrar la alerta
    final player = AudioPlayer();
    player.play(AssetSource('sounds/marge.mp3'));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "¡D'oh!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Para que la columna no ocupe toda la pantalla
            children: [
              // Puedes cambiar la URL por una imagen local si la agregas a tus assets
              Image.asset(
                'assets/marge.png', // Imagen de Marge enojada
                height: 220,
                // --- NUEVO CÓDIGO DE DIAGNÓSTICO AÑADIDO AQUÍ ---
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  // Si hay un error, en lugar de la imagen, muestra este texto.
                  return Text(
                    'Error al cargar la imagen. Razón: $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  );
                },
                // --- FIN DEL CÓDIGO DE DIAGNÓSTICO ---
              ),
              SizedBox(height: 20),
              Text(
                "Hmmm Homero!",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Usamos BlocListener para efectos secundarios (como mostrar un diálogo)
    // y BlocBuilder para construir la UI.
    return BlocListener<BeerCounterBloc, BeerCounterState>(
      listener: (context, state) {
        // Si el estado indica que se debe mostrar la alerta, la mostramos.
        if (state.showHomerAlert) {
          _mostrarAlertaHomero(context);
        }
      },
      child: BlocBuilder<BeerCounterBloc, BeerCounterState>(
        builder: (context, state) {
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
                    value: state.isActive,
                    onChanged: (value) {
                      context.read<BeerCounterBloc>().add(BeerCounterToggled(value));
                    },
                  ),
                ),
              ),

              SizedBox(height: 20),

              if (state.isActive) ...[
                Text(
                  'Cervezas consumidas hoy: ${state.beerCount}',
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
                    // La única responsabilidad del botón es despachar el evento.
                    context.read<BeerCounterBloc>().add(BeerCounterIncremented());
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

              // --- Botón para el Mapa ---
              Card(
                color: Colors.yellow[100],
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.map, color: Colors.yellow[800]),
                  title: Text(
                    'Ver Mapa',
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.yellow[800]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapScreen()),
                    );
                  },
                ),
              ),
              // --- FIN: Botón para el Mapa --
            ],
          );
        },
      ),
    );
  }
}
