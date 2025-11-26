import 'package:equatable/equatable.dart';
import '../../../domain/entities/favorite_order.dart';
import '../../../domain/entities/order.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object> get props => [];
}

class OrdersLoaded extends OrdersEvent {}

class OrderRepeated extends OrdersEvent {
  final FavoriteOrder favorite;
  const OrderRepeated(this.favorite);
  @override
  List<Object> get props => [favorite];
}

class OrderStatusChanged extends OrdersEvent {
  final String orderId;
  final OrderStatus newStatus;
  const OrderStatusChanged(this.orderId, this.newStatus);
  @override
  List<Object> get props => [orderId, newStatus];
}
