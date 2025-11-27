import 'package:equatable/equatable.dart';

abstract class BeerCounterEvent extends Equatable {
  const BeerCounterEvent();

  @override
  List<Object> get props => [];
}

// Evento para incrementar el contador de cervezas.
class BeerCounterIncremented extends BeerCounterEvent {}

// Evento para activar/desactivar el sonido "Woohoo".
class WoohooSoundToggled extends BeerCounterEvent {}

// Evento para resetear el contador de cervezas.
class BeerCounterReset extends BeerCounterEvent {}
