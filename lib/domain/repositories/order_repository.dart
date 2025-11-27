import '../entities/favorite_order.dart';
import '../entities/order.dart';
import '../entities/product.dart';

abstract class OrderRepository {
  Future<List<FavoriteOrder>> getFavoriteOrders(String userId);
  Future<List<Order>> getActiveOrders(String userId);
  Future<void> addOrder(String userId, List<Product> items);
  Future<void> updateOrderStatus(String userId, String orderId, OrderStatus newStatus);
  Future<void> addOrderToFavorites(String userId, Order order);
  Future<void> deleteOrder(String userId, String orderId);
  Future<void> deleteFavoriteOrder(String userId, String favoriteId);
}
