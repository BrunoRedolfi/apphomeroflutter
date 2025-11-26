import 'package:flutter_bloc/flutter_bloc.dart';
import 'beer_counter_event.dart';
import 'beer_counter_state.dart';

class BeerCounterBloc extends Bloc<BeerCounterEvent, BeerCounterState> {
  BeerCounterBloc() : super(const BeerCounterState()) {
    on<BeerCounterToggled>(_onToggled);
    on<BeerCounterIncremented>(_onIncremented);
  }

  void _onToggled(BeerCounterToggled event, Emitter<BeerCounterState> emit) {
    emit(state.copyWith(isActive: event.isActive));
  }

  void _onIncremented(
      BeerCounterIncremented event, Emitter<BeerCounterState> emit) {
    if (!state.isActive) return;

    final newCount = state.beerCount + 1;
    // La alerta se mostrará si el contador es mayor a 20 y si (contador - 1) es múltiplo de 10.
    // Esto hará que suene en 21, 31, 41, etc.
    final bool shouldShowAlert = newCount > 20 && (newCount - 1) % 10 == 0;

    // Emitimos el nuevo estado. Si la alerta se mostró, la "reseteamos"
    // en el siguiente estado para que no se vuelva a mostrar en un rebuild.
    emit(state.copyWith(
      beerCount: newCount,
      showHomerAlert: shouldShowAlert,
    ));
  }
}
