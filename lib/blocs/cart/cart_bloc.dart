import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/beer_model.dart';
import '../../repositories/beer_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final BeerRepository _beerRepository;

  CartBloc({required BeerRepository beerRepository})
      : _beerRepository = beerRepository,
        super(CartLoading()) {
    on<CartProductsLoaded>(_onLoadProducts);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
  }

  Future<void> _onLoadProducts(
      CartProductsLoaded event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final products = await _beerRepository.getBeers();
      emit(CartLoaded(catalog: products, cartItems: []));
    } catch (_) {
      // Manejar error en un futuro
    }
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoaded) {
      final itemIndex =
          state.cartItems.indexWhere((item) => item.name == event.beer.name);
      List<Beer> updatedCart = List.from(state.cartItems);

      if (itemIndex != -1) {
        // El item ya existe, actualizamos la cantidad
        int newQuantity = updatedCart[itemIndex].quantity + 1;
        updatedCart[itemIndex] =
            updatedCart[itemIndex].copyWith(quantity: newQuantity);
      } else {
        // El item es nuevo, lo añadimos con cantidad 1
        updatedCart.add(event.beer.copyWith(quantity: 1));
      }
      emit(CartLoaded(catalog: state.catalog, cartItems: updatedCart));
    }
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final state = this.state;
    if (state is CartLoaded) {
      final itemIndex =
          state.cartItems.indexWhere((item) => item.name == event.beer.name);
      List<Beer> updatedCart = List.from(state.cartItems);

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
}