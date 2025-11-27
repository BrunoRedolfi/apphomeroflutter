import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    required super.type,
    super.quantity,
  });

  // Factory constructor para crear una instancia de ProductModel desde un documento de Firestore
  factory ProductModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ProductModel(
      id: snapshot.id, // Es buena práctica usar el ID del documento de Firestore.
      name: data['name'],
      image: data['image'],
      price: (data['price'] as num).toDouble(), // Aseguramos que sea double.
      type: data['type'] ?? 'generic', // Valor por defecto
      // La cantidad se maneja en el estado del carrito, no se lee del catálogo.
    );
  }
}
