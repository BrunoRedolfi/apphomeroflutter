import 'package:equatable/equatable.dart';
import 'beer.dart';

class FavoriteOrder extends Equatable {
  final int id;
  final List<Beer> items;

  const FavoriteOrder({
    required this.id,
    required this.items,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [id, items];
}
