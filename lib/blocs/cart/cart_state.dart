import 'package:equatable/equatable.dart';
import '../../models/beer_model.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

// Estado mientras se carga el catálogo inicial.
class CartLoading extends CartState {}

// Estado una vez que el catálogo y el carrito están listos.
class CartLoaded extends CartState {
  final List<Beer> catalog;   // Lista completa de productos disponibles.
  final List<Beer> cartItems; // Lista de productos en el carrito.

  const CartLoaded({this.catalog = const [], this.cartItems = const []});

  @override
  List<Object> get props => [catalog, cartItems];
}

// Estado para manejar posibles errores.
class CartError extends CartState {
  final String message;
  const CartError(this.message);

  @override
  List<Object> get props => [message];
}