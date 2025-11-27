import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapController = MapController();
  bool seguirUbicacion = false;

  // Coordenadas
  final LatLng inicio = const LatLng(-32.90294, -68.85880); // ITU
  final LatLng destino = const LatLng(-32.89059, -68.84608); // Taberna Moe Mendoza

  List<LatLng> ruta = [];
  double zoomActual = 15;

  double distanciaKm = 0;
  double duracionMin = 0;

  LatLng? miUbicacion;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    obtenerRuta();
    obtenerUbicacionActual();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // ------------------------------------------------
  // GPS
  // ------------------------------------------------
  Future<void> obtenerUbicacionActual() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition();

    setState(() {
      miUbicacion = LatLng(pos.latitude, pos.longitude);

      if (seguirUbicacion) {
        mapController.move(miUbicacion!, zoomActual);
      }
    });

    // Escuchar movimientos
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position p) {
      if (seguirUbicacion) {
        setState(() {
          miUbicacion = LatLng(p.latitude, p.longitude);
          mapController.move(miUbicacion!, zoomActual);
        });
      }
    });
  }

  // ------------------------------------------------
  // Ruta OSRM
  // ------------------------------------------------
  Future<void> obtenerRuta() async {
    final url =
        "https://router.project-osrm.org/route/v1/driving/${inicio.longitude},${inicio.latitude};${destino.longitude},${destino.latitude}?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List coords =
      data["routes"][0]["geometry"]["coordinates"] as List;

      final distancia = data["routes"][0]["distance"]; // metros
      final duracion = data["routes"][0]["duration"]; // segundos

      setState(() {
        ruta = coords.map((p) => LatLng(p[1], p[0])).toList();

        distanciaKm = distancia / 1000;
        duracionMin = duracion / 60;
      });
    }
  }

  // ------------------------------------------------
  // Zoom
  // ------------------------------------------------
  void acercar() {
    zoomActual += 1;
    mapController.move(mapController.camera.center, zoomActual);
  }

  void alejar() {
    zoomActual -= 1;
    mapController.move(mapController.camera.center, zoomActual);
  }

  // Activar/desactivar seguimiento
  void toggleSeguir() {
    setState(() {
      seguirUbicacion = !seguirUbicacion;
    });

    if (seguirUbicacion && miUbicacion != null) {
      mapController.move(miUbicacion!, zoomActual);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruta hacia la Taberna de Moe"),
        backgroundColor: Colors.yellow[800],
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: inicio,
              zoom: zoomActual,
              maxZoom: 19,
              minZoom: 3,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.tabernademoe.app',
              ),

              // Marcadores
              MarkerLayer(
                markers: [
                  Marker(
                    point: inicio,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.school, color: Colors.blue, size: 40),
                  ),
                  Marker(
                    point: destino,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.local_bar,
                        color: Colors.red, size: 40),
                  ),
                  if (miUbicacion != null)
                    Marker(
                      point: miUbicacion!,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.my_location,
                          color: Colors.green, size: 30),
                    ),
                ],
              ),

              // Ruta marcada
              if (ruta.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: ruta,
                      strokeWidth: 4,
                      color: Colors.deepPurple,
                    )
                  ],
                ),
            ],
          ),

          // ------------------------------------------------
          // DISTANCIA Y DURACIÓN
          // ------------------------------------------------
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Distancia: ${distanciaKm.toStringAsFixed(2)} km\n"
                    "Duración: ${duracionMin.toStringAsFixed(1)} min",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ------------------------------------------------
          // BOTONES DE ZOOM
          // ------------------------------------------------
          Positioned(
            right: 15,
            bottom: 30,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: Colors.yellow[700],
                  child: const Icon(Icons.add, color: Colors.black),
                  onPressed: acercar,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.yellow[700],
                  child: const Icon(Icons.remove, color: Colors.black),
                  onPressed: alejar,
                ),
              ],
            ),
          ),

          // ------------------------------------------------
          // BOTÓN SEGUIR UBICACIÓN
          // ------------------------------------------------
          Positioned(
            left: 15,
            bottom: 30,
            child: FloatingActionButton(
              heroTag: "seguir_btn",
              backgroundColor:
              seguirUbicacion ? Colors.green : Colors.grey[400],
              child: const Icon(Icons.my_location, color: Colors.black),
              onPressed: toggleSeguir,
            ),
          ),
        ],
      ),
    );
  }
}
