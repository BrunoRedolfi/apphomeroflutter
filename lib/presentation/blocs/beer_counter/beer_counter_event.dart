import 'package:equatable/equatable.dart';

abstract class BeerCounterEvent extends Equatable {
  const BeerCounterEvent();

  @override
  List<Object> get props => [];
}

class BeerCounterToggled extends BeerCounterEvent {
  final bool isActive;
  const BeerCounterToggled(this.isActive);

  @override
  List<Object> get props => [isActive];
}

class BeerCounterIncremented extends BeerCounterEvent {}
