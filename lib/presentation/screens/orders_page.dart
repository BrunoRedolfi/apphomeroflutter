import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_homero/domain/entities/beer.dart';import 'package:proyecto_homero/presentation/blocs/cart/cart_bloc.dart';import 'package:proyecto_homero/presentation/blocs/cart/cart_state.dart';
import '../../domain/entities/favorite_order.dart';
import '../../domain/entities/order.dart';
import '../blocs/orders/orders_bloc.dart';
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[600],
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, ordersState) {
          if (ordersState is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ordersState is OrdersLoadSuccess) {
            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final currentCartItems = (cartState is CartLoaded)
                    ? cartState.cartItems
                    : <Beer>[];
                return _buildOrdersList(context, ordersState, currentCartItems);
              },
            );
          }
          if (ordersState is OrdersError) {
            return Center(child: Text(ordersState.message));
          }
          return const Center(child: Text("Algo salió mal."));
        },
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    OrdersLoadSuccess ordersState,
    List<Beer> currentCartItems,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (currentCartItems.isNotEmpty) ...[
          _buildSectionIcon(Icons.hourglass_top_rounded, Colors.orange),
          _buildCurrentOrderCard(context, currentCartItems),
          const SizedBox(height: 24),
        ],
        if (ordersState.favoriteOrders.isNotEmpty) ...[
          _buildSectionIcon(Icons.star, Colors.amber),
          // Usamos asMap().entries para obtener el índice de cada favorito
          ...ordersState.favoriteOrders.asMap().entries.map(
            (entry) {
              return _buildFavoriteCard(context, entry.value, entry.key);
            },
          ),
          const SizedBox(height: 24),
        ],
        _buildSectionIcon(Icons.receipt_long, Colors.blueAccent),
        if (ordersState.activeOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Aún no tienes pedidos.", textAlign: TextAlign.center),
          )
        else
          ...ordersState.activeOrders.asMap().entries.map(
            (entry) {
              // Pasamos el índice para poder numerar los pedidos
              return _buildOrderCard(context, entry.value, entry.key);
            },
          ),
      ],
    );
  }

  Widget _buildCurrentOrderCard(BuildContext context, List<Beer> items) {
    final total = items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    return Card(
      color: Colors.yellow[200],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...items.map(
              (item) => Text(
                '${item.name} x${item.quantity}',
                style: TextStyle(fontSize: 25),
              ),
            ),
            const Divider(),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[500],
                  ),
                  icon: const Icon(Icons.check, size: 50),
                  label: const Text(''),
                  onPressed: () {
                    context.read<OrdersBloc>().add(OrderConfirmed());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Center(
        child: Icon(
          icon,
          size: 50,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteOrder favorite, int index) {
    return Card(
      color: Colors.yellow[200],
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        // Usamos el índice + 1 para mostrar "1", "2", etc.
        title: Text(
          'Favorito #${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Text('🍺x${favorite.totalItems}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón para repetir el pedido
            IconButton(
              icon: const Icon(Icons.repeat, color: Colors.green, size: 30),
              onPressed: () {
                context.read<OrdersBloc>().add(FavoriteOrderRepeated(favorite));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Favorito #${index + 1} agregado al pedido!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            // Botón para eliminar el favorito
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 30),
              onPressed: () {
                context.read<OrdersBloc>().add(FavoriteOrderDeleted(favorite.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, int index) {
    return Card(
      color: Colors.yellow[200],
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          order.status == OrderStatus.llegando ? Icons.delivery_dining : Icons.receipt_long,
          color: Colors.blueAccent,
        ),
        title: Text(
          'Pedido #${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Text('🍺x${order.totalItems} - ${order.statusText}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón para añadir a favoritos (siempre visible)
            IconButton(
              icon: const Icon(Icons.star_border, color: Colors.amber),
              onPressed: () {
                context.read<OrdersBloc>().add(OrderAddedToFavorites(order));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pedido guardado en favoritos!'), backgroundColor: Colors.amber),
                );
              },
            ),

            // Botones condicionales para pedidos activos
            if (order.status == OrderStatus.enProceso ||
                order.status == OrderStatus.llegando)
              ...[
                // Botón para cancelar
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () => context.read<OrdersBloc>().add(OrderStatusChanged(order.id, OrderStatus.cancelado)),
                ),
                // Botón para confirmar entrega
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  onPressed: () => context.read<OrdersBloc>().add(OrderStatusChanged(order.id, OrderStatus.entregado)),
                ),
              ],

            // Botón para eliminar pedidos finalizados
            if (order.status == OrderStatus.entregado ||
                order.status == OrderStatus.cancelado)
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () {
                  context.read<OrdersBloc>().add(OrderDeleted(order.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pedido eliminado del historial.'), backgroundColor: Colors.red),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
