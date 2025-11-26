import '../../domain/entities/beer.dart';
import '../../domain/entities/favorite_order.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  @override
  Future<List<FavoriteOrder>> getFavoriteOrders() async {
    // Simulamos una llamada a una API
    await Future.delayed(const Duration(milliseconds: 800));
    return const [
      FavoriteOrder(id: 1, items: [
        Beer(id: '1', name: 'Duff', price: 1.50, image: 'assets/duff.png', quantity: 6),
        Beer(id: '2', name: 'Duff Lite', price: 1.25, image: 'assets/duff_lite.png', quantity: 6),
      ]),
      FavoriteOrder(id: 2, items: [
        Beer(id: '3', name: 'Duff Dry', price: 1.75, image: 'assets/duff_dry.png', quantity: 12),
      ]),
    ];
  }

  @override
  Future<List<Order>> getActiveOrders() async {
    // Simulamos otra llamada a una API
    await Future.delayed(const Duration(milliseconds: 1200));
    return [
      Order(
        id: 'ORD-001',
        items: const [
          Beer(id: '1', name: 'Duff', price: 1.50, image: 'assets/duff.png', quantity: 2),
        ],
        date: DateTime.now().subtract(const Duration(minutes: 15)),
        status: OrderStatus.enProceso,
      ),
      Order(
        id: 'ORD-002',
        items: const [
          Beer(id: '4', name: 'Fudd', price: 1.0, image: 'assets/fudd.png', quantity: 4),
        ],
        date: DateTime.now().subtract(const Duration(hours: 1)),
        status: OrderStatus.llegando,
      ),
    ];
  }
}
