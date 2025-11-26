import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:intl/intl.dart'; // Necesario para el nombre del favorito
import '../../domain/entities/beer.dart';
import '../../domain/entities/favorite_order.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userOrders(String userId) =>
      _firestore.collection('users').doc(userId).collection('orders');

  CollectionReference<Map<String, dynamic>> _userFavorites(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorites');

  @override
  Future<List<FavoriteOrder>> getFavoriteOrders(String userId) async {
    final snapshot = await _userFavorites(userId).get();
    return snapshot.docs.map((doc) => FavoriteOrder.fromSnapshot(doc)).toList();
  }

  @override
  Future<List<Order>> getActiveOrders(String userId) async {
    final snapshot = await _userOrders(userId).orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Order.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> addOrder(String userId, List<Beer> items) async {
    final newOrderRef = _userOrders(userId).doc();
    final itemsMap = items.map((item) => {
      'id': item.id,
      'name': item.name,
      'price': item.price,
      'image': item.image,
      'quantity': item.quantity,
    }).toList();

    await newOrderRef.set({
      'date': FieldValue.serverTimestamp(),
      'status': 'enProceso',
      'items': itemsMap,
    });
  }

  @override
  Future<void> updateOrderStatus(String userId, String orderId, OrderStatus newStatus) async {
    await _userOrders(userId).doc(orderId).update({'status': newStatus.name});
  }

  @override
  Future<void> addOrderToFavorites(String userId, Order order) async {
    final newFavoriteRef = _userFavorites(userId).doc();
    final itemsMap = order.items.map((item) => {
      'id': item.id,
      'name': item.name,
      'price': item.price,
      'image': item.image,
      'quantity': item.quantity,
    }).toList();

    await newFavoriteRef.set({
      'name': 'Favorito del ${DateFormat('dd/MM/yy').format(order.date)}',
      'items': itemsMap,
    });
  }

  @override
  Future<void> deleteOrder(String userId, String orderId) async {
    await _userOrders(userId).doc(orderId).delete();
  }

  @override
  Future<void> deleteFavoriteOrder(String userId, String favoriteId) async {
    await _userFavorites(userId).doc(favoriteId).delete();
  }
}
