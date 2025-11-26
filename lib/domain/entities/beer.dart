import 'package:equatable/equatable.dart';

class Beer extends Equatable {
  final String id; // <-- CAMBIO: Añadido
  final String name;
  final double price;
  final String image;
  final int quantity;

  const Beer({
    required this.id, // <-- CAMBIO: Añadido
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 0,
  });

  factory Beer.fromMap(Map<String, dynamic> map) {
    return Beer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
      quantity: (map['quantity'] as int?) ?? 0,
    );
  }

  Beer copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    int? quantity,
  }) {
    return Beer(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, name, price, image, quantity];
}
