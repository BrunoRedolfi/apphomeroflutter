import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String image;
  final String type; // 'beer', 'food', etc.
  final int quantity;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.type,
    this.quantity = 0,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
      type: map['type'] ?? 'generic',
      quantity: (map['quantity'] as int?) ?? 0,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? type,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, name, price, image, type, quantity];
}