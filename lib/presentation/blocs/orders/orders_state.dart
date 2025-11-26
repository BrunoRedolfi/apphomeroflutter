part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object> get props => [];
}

class OrdersLoading extends OrdersState {}

class OrdersLoadSuccess extends OrdersState {
  final List<FavoriteOrder> favoriteOrders;
  final List<Order> activeOrders;

  const OrdersLoadSuccess({
    this.favoriteOrders = const [],
    this.activeOrders = const [],
  });

  @override
  List<Object> get props => [favoriteOrders, activeOrders];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
  @override
  List<Object> get props => [message];
}
