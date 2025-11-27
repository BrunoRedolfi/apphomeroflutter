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

// Evento para incrementar el contador de cervezas.
class BeerCounterIncremented extends BeerCounterEvent {}

// Evento para activar/desactivar el sonido "Woohoo".
class WoohooSoundToggled extends BeerCounterEvent {}
