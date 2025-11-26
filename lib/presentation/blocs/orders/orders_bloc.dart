import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto_homero/domain/entities/favorite_order.dart';
import 'package:proyecto_homero/domain/entities/order.dart';
import 'package:proyecto_homero/domain/repositories/order_repository.dart';
import 'package:proyecto_homero/presentation/blocs/auth/auth_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/cart/cart_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/cart/cart_event.dart';
import 'package:proyecto_homero/presentation/blocs/cart/cart_state.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _orderRepository;
  final AuthBloc _authBloc;
  final CartBloc _cartBloc;
  late StreamSubscription _authSubscription;

  OrdersBloc({
    required OrderRepository orderRepository,
    required AuthBloc authBloc,
    required CartBloc cartBloc,
  })  : _orderRepository = orderRepository,
        _authBloc = authBloc,
        _cartBloc = cartBloc,
        super(OrdersLoading()) {
    on<OrdersLoaded>(_onOrdersLoaded);
    on<OrderConfirmed>(_onOrderConfirmed);
    on<OrderStatusChanged>(_onOrderStatusChanged);
    on<OrderAddedToFavorites>(_onOrderAddedToFavorites);
    on<FavoriteOrderRepeated>(_onFavoriteOrderRepeated);
    on<OrderDeleted>(_onOrderDeleted);
    on<FavoriteOrderDeleted>(_onFavoriteOrderDeleted);

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        // Cuando el usuario se autentica, cargamos sus pedidos.
        add(OrdersLoaded());
      }
      // Podríamos añadir lógica para limpiar los pedidos si el usuario hace logout.
    });
  }

  String? get _userId => _authBloc.state.user?.uid;

  Future<void> _onOrdersLoaded(OrdersLoaded event, Emitter<OrdersState> emit) async {
    if (_userId == null) return;
    emit(OrdersLoading());
    try {
      final favs = await _orderRepository.getFavoriteOrders(_userId!);
      final active = await _orderRepository.getActiveOrders(_userId!);
      emit(OrdersLoadSuccess(favoriteOrders: favs, activeOrders: active));
    } catch (e) {
      emit(OrdersError("D'oh! No se pudieron cargar los pedidos: $e"));
    }
  }

  Future<void> _onOrderConfirmed(OrderConfirmed event, Emitter<OrdersState> emit) async {
    if (_userId == null || _cartBloc.state is! CartLoaded) return;
    final cartState = _cartBloc.state as CartLoaded;
    if (cartState.cartItems.isEmpty) return;

    await _orderRepository.addOrder(_userId!, cartState.cartItems);
    _cartBloc.add(CartCleared());
    add(OrdersLoaded()); // Recargamos la lista de pedidos
  }

  Future<void> _onOrderStatusChanged(OrderStatusChanged event, Emitter<OrdersState> emit) async {
    if (_userId == null) return;
    await _orderRepository.updateOrderStatus(_userId!, event.orderId, event.newStatus);
    add(OrdersLoaded());
  }

  Future<void> _onOrderAddedToFavorites(OrderAddedToFavorites event, Emitter<OrdersState> emit) async {
    if (_userId == null) return;
    await _orderRepository.addOrderToFavorites(_userId!, event.order);
    add(OrdersLoaded());
  }

  void _onFavoriteOrderRepeated(FavoriteOrderRepeated event, Emitter<OrdersState> emit) {
    _cartBloc.add(CartReplacedWithItems(event.favorite.items));
  }

  Future<void> _onOrderDeleted(OrderDeleted event, Emitter<OrdersState> emit) async {
    if (_userId == null) return;
    await _orderRepository.deleteOrder(_userId!, event.orderId);
    add(OrdersLoaded()); // Recargamos la lista para reflejar el borrado
  }

  Future<void> _onFavoriteOrderDeleted(FavoriteOrderDeleted event, Emitter<OrdersState> emit) async {
    if (_userId == null) return;
    await _orderRepository.deleteFavoriteOrder(_userId!, event.favoriteId);
    add(OrdersLoaded()); // Recargamos la lista
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
