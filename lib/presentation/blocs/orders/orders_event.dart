part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object> get props => [];
}

class OrdersLoaded extends OrdersEvent {}

class OrderConfirmed extends OrdersEvent {}

class FavoriteOrderRepeated extends OrdersEvent {
  final FavoriteOrder favorite;
  const FavoriteOrderRepeated(this.favorite);

  @override
  List<Object> get props => [favorite];
}

class OrderDeleted extends OrdersEvent {
  final String orderId;
  const OrderDeleted(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class FavoriteOrderDeleted extends OrdersEvent {
  final String favoriteId;
  const FavoriteOrderDeleted(this.favoriteId);

  @override
  List<Object> get props => [favoriteId];
}

class OrderAddedToFavorites extends OrdersEvent {
  final Order order;
  const OrderAddedToFavorites(this.order);
  @override
  List<Object> get props => [order];
}

class OrderStatusChanged extends OrdersEvent {
  final String orderId;
  final OrderStatus newStatus;
  const OrderStatusChanged(this.orderId, this.newStatus);
  @override
  List<Object> get props => [orderId, newStatus];
}