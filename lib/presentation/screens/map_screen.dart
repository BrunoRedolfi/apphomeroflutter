import 'package:flutter/material.dart';

// 1. Convertido a StatefulWidget
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 2. Controlador para manipular el InteractiveViewer
  final TransformationController _transformationController = TransformationController();

  // Constantes para el zoom
  final double _minScale = 0.5;
  final double _maxScale = 4.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Springfield', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.yellow[700],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[850],
      // 3. Usamos un Stack para poner los botones sobre el mapa
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              // 4. Conectamos el controlador
              transformationController: _transformationController,
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: _minScale,
              maxScale: _maxScale,
              child: Image.asset(
                'assets/mapa_springfield.jpg', // Reemplaza con el nombre de tu imagen
              ),
            ),
          ),
          // 5. Posicionamos los botones de zoom
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn', // Tag único para el Hero
                  mini: true,
                  backgroundColor: Colors.yellow[700],
                  child: const Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    // Lógica para hacer zoom in
                    final currentScale = _transformationController.value.getMaxScaleOnAxis();
                    final newScale = (currentScale * 1.2).clamp(_minScale, _maxScale);
                    final zoomedMatrix = Matrix4.identity()
                      ..translate(context.size!.width / 2, context.size!.height / 2)
                      ..scale(newScale)
                      ..translate(-context.size!.width / 2, -context.size!.height / 2);

                    _transformationController.value = zoomedMatrix;
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut', // Tag único para el Hero
                  mini: true,
                  backgroundColor: Colors.yellow[700],
                  child: const Icon(Icons.remove, color: Colors.black),
                  onPressed: () {
                    // Lógica para hacer zoom out
                    final currentScale = _transformationController.value.getMaxScaleOnAxis();
                    final newScale = (currentScale * 0.8).clamp(_minScale, _maxScale);
                    final zoomedMatrix = Matrix4.identity()
                      ..translate(context.size!.width / 2, context.size!.height / 2)
                      ..scale(newScale)
                      ..translate(-context.size!.width / 2, -context.size!.height / 2);

                    _transformationController.value = zoomedMatrix;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}