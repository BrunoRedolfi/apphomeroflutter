import 'package:equatable/equatable.dart';

class BeerCounterState extends Equatable {
  final bool isActive;
  final int beerCount;

  const BeerCounterState({
    required this.isActive,
    required this.beerCount,
  });

  factory BeerCounterState.initial() {
    return const BeerCounterState(isActive: false, beerCount: 0);
  }

  BeerCounterState copyWith({
    bool? isActive,
    int? beerCount,
  }) {
    return BeerCounterState(
      isActive: isActive ?? this.isActive,
      beerCount: beerCount ?? this.beerCount,
    );
  }

  @override
  List<Object> get props => [isActive, beerCount];
}
