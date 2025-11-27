import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'product.dart';

enum OrderStatus { enProceso, llegando, cancelado, entregado }

class Order extends Equatable {
  final String id;
  final List<Product> items;
  final DateTime date;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.items,
    required this.date,
    required this.status,
  });

  factory Order.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      items: (data['items'] as List).map((itemData) => Product.fromMap(itemData)).toList(),
      date: (data['date'] as Timestamp).toDate(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.enProceso,
      ),
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusText {
    switch (status) {
      case OrderStatus.enProceso: return 'En proceso';
      case OrderStatus.llegando: return 'Llegando';
      case OrderStatus.cancelado: return 'Cancelado';
      case OrderStatus.entregado: return 'Entregado';
    }
  }

  @override
  List<Object?> get props => [id, items, date, status];
}