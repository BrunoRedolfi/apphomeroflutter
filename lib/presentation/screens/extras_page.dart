import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
// para agregar map_screen al proyecto
import 'package:proyecto_homero/presentation/screens/map_page.dart';
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
        // Si el estado indica que se debe mostrar el recordatorio de agua, reproducimos el sonido.
        if (state.showWaterReminder) {
          // Asumiendo que has añadido un sonido 'water_pour.wav' a 'assets/sounds/'
          final player = AudioPlayer();
          player.play(AssetSource('sounds/water_pour.wav'));
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

              // --- Contador de Cervezas Integrado ---
              Card(
                color: Colors.yellow[100],
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Contador Visual ---
                      Row(
                        children: [
                          Icon(Icons.sports_bar, color: Colors.brown[700], size: 50),
                          SizedBox(width: 10),
                          Text(
                            '${state.beerCount}',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // --- Botón de Añadir Visual ---
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          foregroundColor: Colors.black,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        onPressed: () {
                          context.read<BeerCounterBloc>().add(BeerCounterIncremented());
                        },
                        child: Icon(Icons.add, size: 40),
                      ),
                    ],
                  ),
                ),
              ),
              // --- Fin del Contador de Cervezas ---

              // --- Botón para el Mapa ---
              Card(
                color: Colors.yellow[100],
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapPage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Icon(Icons.map, color: Colors.yellow[800], size: 50),
                  ),
                ),
              ),
              // --- FIN: Botón para el Mapa --

              // --- NUEVO: Recordatorio de Agua Condicional ---
              if (state.showWaterReminder)
                Card(
                  color: Colors.lightBlue[50],
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_drink, color: Colors.blue[600], size: 40),
                        SizedBox(width: 15),
                        Text("AGUA!!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                      ],
                    ),
                  ),
                ),
              // --- FIN: Recordatorio de Agua ---
            ],
          );
        },
      ),
    );
  }
}
