import 'package:flutter_bloc/flutter_bloc.dart';
import 'beer_counter_event.dart';
import 'beer_counter_state.dart';

class BeerCounterBloc extends Bloc<BeerCounterEvent, BeerCounterState> {
  BeerCounterBloc() : super(BeerCounterState.initial()) {
    on<BeerCounterToggled>(_onToggled);
    on<BeerCounterIncremented>(_onIncremented);
  }

  void _onToggled(BeerCounterToggled event, Emitter<BeerCounterState> emit) {
    if (event.isActive) {
      // Si se activa, solo cambiamos el estado
      emit(state.copyWith(isActive: true));
    } else {
      // Si se desactiva, reseteamos el contador y el estado
      emit(state.copyWith(isActive: false, beerCount: 0));
    }
  }

  void _onIncremented(
      BeerCounterIncremented event, Emitter<BeerCounterState> emit) {
    if (state.isActive) {
      emit(state.copyWith(beerCount: state.beerCount + 1));
    }
  }
}
