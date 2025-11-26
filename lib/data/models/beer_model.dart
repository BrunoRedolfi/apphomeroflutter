import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/beer.dart';

class BeerModel extends Beer {
  const BeerModel({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    super.quantity,
  });

  // Factory constructor para crear una instancia de BeerModel desde un documento de Firestore
  factory BeerModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BeerModel(
      id: snapshot.id, // Es buena práctica usar el ID del documento de Firestore.
      name: data['name'],
      image: data['image'],
      price: (data['price'] as num).toDouble(), // Aseguramos que sea double.
      // No leemos 'quantity' desde el catálogo. Se manejará en el estado del carrito.
    );
  }
}
