import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/repositories/order_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _orderRepository;

  OrdersBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrdersLoading()) {
    on<OrdersLoaded>(_onOrdersLoaded);
    on<OrderRepeated>(_onOrderRepeated);
    on<OrderStatusChanged>(_onOrderStatusChanged);
  }

  Future<void> _onOrdersLoaded(
      OrdersLoaded event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try {
      final favs = await _orderRepository.getFavoriteOrders();
      final active = await _orderRepository.getActiveOrders();
      emit(OrdersLoadSuccess(favoriteOrders: favs, activeOrders: active));
    } catch (_) {
      emit(const OrdersError("D'oh! No se pudieron cargar los pedidos."));
    }
  }

  void _onOrderRepeated(OrderRepeated event, Emitter<OrdersState> emit) {
    if (state is OrdersLoadSuccess) {
      final currentState = state as OrdersLoadSuccess;
      final newOrder = Order(
        id: 'ORD-${Random().nextInt(900) + 100}', // ID aleatorio
        items: event.favorite.items,
        date: DateTime.now(),
        status: OrderStatus.enProceso,
      );

      final updatedActiveOrders = List<Order>.from(currentState.activeOrders)
        ..insert(0, newOrder);

      emit(OrdersLoadSuccess(
        favoriteOrders: currentState.favoriteOrders,
        activeOrders: updatedActiveOrders,
      ));
    }
  }

  void _onOrderStatusChanged(
      OrderStatusChanged event, Emitter<OrdersState> emit) {
    if (state is OrdersLoadSuccess) {
      final currentState = state as OrdersLoadSuccess;
      final updatedOrders = currentState.activeOrders.map((order) {
        return order.id == event.orderId
            ? Order(id: order.id, items: order.items, date: order.date, status: event.newStatus)
            : order;
      }).toList();

      emit(OrdersLoadSuccess(
          favoriteOrders: currentState.favoriteOrders,
          activeOrders: updatedOrders));
    }
  }
}
