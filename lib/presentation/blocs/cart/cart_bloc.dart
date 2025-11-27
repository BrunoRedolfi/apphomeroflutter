import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ProductRepository _beerRepository;

  CartBloc({required ProductRepository beerRepository})
      : _beerRepository = beerRepository,
        super(CartLoading()) {
    on<CartProductsLoaded>(_onLoadProducts);
    on<CartItemAdded>(_onItemAdded);
    on<CartReplacedWithItems>(_onCartReplacedWithItems);
    on<CartCleared>(_onCartCleared);
    on<CartItemRemoved>(_onItemRemoved);
  }

  Future<void> _onLoadProducts(
      CartProductsLoaded event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final products = await _beerRepository.getBeerCatalog();
      emit(CartLoaded(catalog: products, cartItems: []));
    } catch (_) {
      emit(const CartError("D'oh! No se pudieron cargar las cervezas."));
    }
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoaded) {
      final itemIndex =
          state.cartItems.indexWhere((item) => item.id == event.product.id);
      List<Product> updatedCart = List.from(state.cartItems);

      if (itemIndex != -1) {
        // El item ya existe, actualizamos la cantidad
        int newQuantity = updatedCart[itemIndex].quantity + 1;
        updatedCart[itemIndex] =
            updatedCart[itemIndex].copyWith(quantity: newQuantity);
      } else {
        // El item es nuevo, lo añadimos con cantidad 1
        updatedCart.add(event.product.copyWith(quantity: 1));
      }
      emit(CartLoaded(catalog: state.catalog, cartItems: updatedCart));
    }
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoaded) {
      final itemIndex =
          state.cartItems.indexWhere((item) => item.id == event.product.id);
      List<Product> updatedCart = List.from(state.cartItems);

      if (itemIndex != -1 && updatedCart[itemIndex].quantity > 1) {
        int newQuantity = updatedCart[itemIndex].quantity - 1;
        updatedCart[itemIndex] =
            updatedCart[itemIndex].copyWith(quantity: newQuantity);
      } else {
        updatedCart.removeAt(itemIndex);
      }
      emit(CartLoaded(catalog: state.catalog, cartItems: updatedCart));
    }
  }

  void _onCartCleared(CartCleared event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoaded) {
      emit(CartLoaded(catalog: state.catalog, cartItems: const []));
    }
  }

  void _onCartReplacedWithItems(CartReplacedWithItems event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoaded) {
      emit(CartLoaded(catalog: state.catalog, cartItems: event.items));
    }
  }
}