import 'package:equatable/equatable.dart';
import 'beer.dart';

enum OrderStatus { enProceso, llegando, cancelado, entregado }

class Order extends Equatable {
  final String id;
  final List<Beer> items;
  final DateTime date;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.items,
    required this.date,
    required this.status,
  });

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
