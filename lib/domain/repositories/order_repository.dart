import '../entities/favorite_order.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<FavoriteOrder>> getFavoriteOrders();
  Future<List<Order>> getActiveOrders();
}
