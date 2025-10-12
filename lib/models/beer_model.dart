import 'package:equatable/equatable.dart';

class Beer extends Equatable {
  final String name;
  final String image;
  final int quantity;

  const Beer({
    required this.name,
    required this.image,
    this.quantity = 0,
  });

  // Creamos una copia del objeto con valores actualizados, promoviendo la inmutabilidad
  Beer copyWith({int? quantity}) {
    return Beer(
      name: name,
      image: image,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [name, image, quantity];
}