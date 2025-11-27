import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'beer_counter_event.dart';
import 'beer_counter_state.dart';

class BeerCounterBloc extends HydratedBloc<BeerCounterEvent, BeerCounterState> {
  BeerCounterBloc() : super(const BeerCounterState()) {
    on<BeerCounterIncremented>(_onIncremented);
    on<WoohooSoundToggled>(_onWoohooSoundToggled);
    on<BeerCounterReset>(_onReset);
  }

  void _onIncremented(
      BeerCounterIncremented event, Emitter<BeerCounterState> emit) {
    // Ya no es necesario comprobar si está activo, el contador siempre funciona.
    
    final newCount = state.beerCount + 1;
    // La alerta se mostrará si el contador es mayor a 20 y termina en 1.
    // Esto hará que suene en 21, 31, 41, etc.
    final bool shouldShowAlert = newCount > 20 && newCount % 10 == 1;

    // El recordatorio de agua se mostrará cada 5 cervezas (5, 10, 15...).
    // Nos aseguramos de que no se muestre en 0.
    final bool shouldShowWaterReminder = newCount > 0 && newCount % 5 == 0;

    // Emitimos el nuevo estado. Si la alerta se mostró, la "reseteamos"
    // en el siguiente estado para que no se vuelva a mostrar en un rebuild.
    emit(state.copyWith(
      beerCount: newCount,
      showHomerAlert: shouldShowAlert,
      showWaterReminder: shouldShowWaterReminder,
    ));
  }

  void _onWoohooSoundToggled(
      WoohooSoundToggled event, Emitter<BeerCounterState> emit) {
    emit(state.copyWith(isWoohooSoundEnabled: !state.isWoohooSoundEnabled));
  }

  void _onReset(BeerCounterReset event, Emitter<BeerCounterState> emit) {
    // Reseteamos el contador y los recordatorios.
    emit(state.copyWith(
      beerCount: 0,
      showHomerAlert: false,
      showWaterReminder: false,
    ));
  }

  // --- MÉTODOS REQUERIDOS POR HYDRATED BLOC ---

  @override
  BeerCounterState? fromJson(Map<String, dynamic> json) {
    return BeerCounterState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(BeerCounterState state) {
    return state.toMap();
  }
}
