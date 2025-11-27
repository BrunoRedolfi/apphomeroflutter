import 'package:equatable/equatable.dart';

class BeerCounterState extends Equatable {
  final int beerCount;
  final bool showHomerAlert;
  final bool showWaterReminder;
  final bool isWoohooSoundEnabled;

  const BeerCounterState({
    this.beerCount = 0,
    this.showHomerAlert = false,
    this.showWaterReminder = false,
    this.isWoohooSoundEnabled = true, // Activado por defecto
  });

  BeerCounterState copyWith({
    int? beerCount,
    bool? showHomerAlert,
    bool? showWaterReminder,
    bool? isWoohooSoundEnabled,
  }) {
    return BeerCounterState(
      beerCount: beerCount ?? this.beerCount,
      showHomerAlert: showHomerAlert ?? this.showHomerAlert,
      showWaterReminder: showWaterReminder ?? this.showWaterReminder,
      isWoohooSoundEnabled: isWoohooSoundEnabled ?? this.isWoohooSoundEnabled,
    );
  }

  // --- Métodos para HydratedBloc ---

  factory BeerCounterState.fromMap(Map<String, dynamic> map) {
    return BeerCounterState(
      beerCount: map['beerCount'] as int? ?? 0,
      showHomerAlert: map['showHomerAlert'] as bool? ?? false,
      showWaterReminder: map['showWaterReminder'] as bool? ?? false,
      // Si el valor no existe en el JSON (la primera vez), lo ponemos en true.
      isWoohooSoundEnabled: map['isWoohooSoundEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'beerCount': beerCount,
      'showHomerAlert': showHomerAlert,
      'showWaterReminder': showWaterReminder,
      'isWoohooSoundEnabled': isWoohooSoundEnabled,
    };
  }

  @override
  List<Object> get props => [beerCount, showHomerAlert, showWaterReminder, isWoohooSoundEnabled];
}
