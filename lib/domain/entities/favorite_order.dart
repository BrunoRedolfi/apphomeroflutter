import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'product.dart';

class FavoriteOrder extends Equatable {
  final String id;
  final String name;
  final List<Product> items;

  const FavoriteOrder({
    required this.id,
    required this.name,
    required this.items,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  factory FavoriteOrder.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteOrder(
      id: doc.id,
      name: data['name'] ?? 'Pedido Favorito',
      items: (data['items'] as List).map((itemData) => Product.fromMap(itemData)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, items];
}