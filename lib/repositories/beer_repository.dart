import '../models/beer_model.dart';

class BeerRepository {
  // En una app real, esto haría una llamada a una API o base de datos.
  // Usamos un Future para simular esa asincronía.
  Future<List<Beer>> getBeers() async {
    // Simulamos un pequeño retraso de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Aquí vive ahora nuestro catálogo de productos
    return [
      Beer(name: 'Duff Normal', image: 'assets/duff_normal.png'),
      Beer(name: 'Duff Light', image: 'assets/duff_light.png'),
      Beer(name: 'Duff Dry', image: 'assets/duff_dry.png'),
      Beer(name: 'Duff Christmas', image: 'assets/duff_christmas.png'),
    ];
  }
}