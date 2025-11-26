import 'package:equatable/equatable.dart';

class BeerCounterState extends Equatable {
  final int beerCount;
  final bool isActive;
  final bool showHomerAlert; // <-- NUEVA PROPIEDAD

  const BeerCounterState({
    this.beerCount = 0,
    this.isActive = false,
    this.showHomerAlert = false, // <-- VALOR POR DEFECTO
  });

  BeerCounterState copyWith({
    int? beerCount,
    bool? isActive,
    bool? showHomerAlert,
  }) {
    return BeerCounterState(
      beerCount: beerCount ?? this.beerCount,
      isActive: isActive ?? this.isActive,
      showHomerAlert: showHomerAlert ?? this.showHomerAlert,
    );
  }

  @override
  List<Object> get props => [beerCount, isActive, showHomerAlert];
}