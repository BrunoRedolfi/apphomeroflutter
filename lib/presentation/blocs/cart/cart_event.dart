import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

// Evento para solicitar la carga del catálogo de productos.
class CartProductsLoaded extends CartEvent {}

// Evento para añadir o incrementar un producto en el carrito.
class CartItemAdded extends CartEvent {
  final Product product;
  const CartItemAdded(this.product);

  @override
  List<Object> get props => [product];
}

// Evento para reemplazar el carrito con una lista de items (usado para repetir favoritos).
class CartReplacedWithItems extends CartEvent {
  final List<Product> items;
  const CartReplacedWithItems(this.items);

  @override
  List<Object> get props => [items];
}

// Evento para limpiar el carrito después de confirmar un pedido.
class CartCleared extends CartEvent {}

// Evento para quitar o decrementar un producto del carrito.
class CartItemRemoved extends CartEvent {
  final Product product;
  const CartItemRemoved(this.product);

  @override
  List<Object> get props => [product];
}