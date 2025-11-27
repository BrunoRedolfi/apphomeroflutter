import 'package:equatable/equatable.dart';
import 'dart:convert';
class BeerCounterState extends Equatable {
  final int beerCount;
  final bool showHomerAlert;
  final bool showWaterReminder; // <-- NUEVA PROPIEDAD PARA EL AGUA

  const BeerCounterState({
    this.beerCount = 0,
    this.showHomerAlert = false,
    this.showWaterReminder = false, // <-- VALOR POR DEFECTO
  });

  BeerCounterState copyWith({
    int? beerCount,
    bool? showHomerAlert,
    bool? showWaterReminder,
  }) {
    return BeerCounterState(
      beerCount: beerCount ?? this.beerCount,
      showHomerAlert: showHomerAlert ?? this.showHomerAlert,
      showWaterReminder: showWaterReminder ?? this.showWaterReminder,
    );
  }

  @override
  List<Object> get props => [beerCount, showHomerAlert, showWaterReminder];

  Map<String, dynamic> toMap() {
    return {
      'beerCount': beerCount,
      // No guardamos 'showHomerAlert' porque es un estado transitorio.
    };
  }

  factory BeerCounterState.fromMap(Map<String, dynamic> map) {
    return BeerCounterState(
      beerCount: map['beerCount']?.toInt() ?? 0,
      // 'showHomerAlert' siempre se inicializa en false al cargar.
    );
  }

  String toJson() => json.encode(toMap());

  factory BeerCounterState.fromJson(String source) =>
      BeerCounterState.fromMap(json.decode(source));
}