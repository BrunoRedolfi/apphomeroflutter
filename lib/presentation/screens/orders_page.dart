import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_homero/domain/entities/beer.dart';
import 'package:proyecto_homero/presentation/blocs/cart/cart_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/cart/cart_state.dart';
import '../../domain/entities/favorite_order.dart';
import '../../domain/entities/order.dart';
import '../blocs/orders/orders_bloc.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, ordersState) {
          if (ordersState is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ordersState is OrdersLoadSuccess) {
            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final currentCartItems = (cartState is CartLoaded) ? cartState.cartItems : <Beer>[];
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

  Widget _buildOrdersList(BuildContext context, OrdersLoadSuccess ordersState, List<Beer> currentCartItems) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (currentCartItems.isNotEmpty) ...[
          _buildSectionTitle('Pedido Actual'),
          _buildCurrentOrderCard(context, currentCartItems),
          const SizedBox(height: 24),
        ],
        if (ordersState.favoriteOrders.isNotEmpty) ...[
          _buildSectionTitle('Favoritos'),
          ...ordersState.favoriteOrders.map((fav) => _buildFavoriteCard(context, fav)),
          const SizedBox(height: 24),
        ],
        _buildSectionTitle('Historial de Pedidos'),
        if (ordersState.activeOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Aún no tienes pedidos.", textAlign: TextAlign.center),
          )
        else
          ...ordersState.activeOrders.map((order) => _buildOrderCard(context, order)),
      ],
    );
  }

  Widget _buildCurrentOrderCard(BuildContext context, List<Beer> items) {
    final total = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    return Card(
      color: Colors.yellow[200],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...items.map((item) => Text('${item.name} x${item.quantity}')),
            const Divider(),
            Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Confirmar Pedido'),
                onPressed: () {
                  context.read<OrdersBloc>().add(OrderConfirmed());
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteOrder favorite) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text(favorite.name),
        subtitle: Text('${favorite.totalItems} productos'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'repeat') {
              context.read<OrdersBloc>().add(FavoriteOrderRepeated(favorite));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${favorite.name}" se ha añadido a tu pedido actual.'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (value == 'delete') {
              context.read<OrdersBloc>().add(FavoriteOrderDeleted(favorite.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${favorite.name}" eliminado.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'repeat',
              child: ListTile(
                leading: Icon(Icons.repeat),
                title: Text('Repetir Pedido'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar Favorito'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Icon(
            order.status == OrderStatus.llegando ? Icons.delivery_dining : Icons.receipt_long,
            color: Colors.blueAccent,
          ),
          title: Text('Pedido del ${DateFormat('dd/MM/yyyy HH:mm').format(order.date)}'),
          subtitle: Text('${order.totalItems} productos - ${order.statusText}'),
          trailing: PopupMenuButton<String>(
            // El menú de opciones para los pedidos del historial
            onSelected: (value) {
              if (value == 'favorite') {
                context.read<OrdersBloc>().add(OrderAddedToFavorites(order));
              } else if (value == 'cancel') {
                context.read<OrdersBloc>().add(OrderStatusChanged(order.id, OrderStatus.cancelado));
              } else if (value == 'confirm') {
                context.read<OrdersBloc>().add(OrderStatusChanged(order.id, OrderStatus.entregado));
              } else if (value == 'delete') {
                context.read<OrdersBloc>().add(OrderDeleted(order.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido eliminado del historial.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'favorite',
                child: ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text('Añadir a favoritos'),
                ),
              ),
              // --- INICIO DEL CAMBIO ---
              // Solo mostramos la opción de cancelar si el pedido está en un estado cancelable.
              if (order.status == OrderStatus.enProceso || order.status == OrderStatus.llegando)
                const PopupMenuItem<String>(
                  value: 'cancel',
                  child: ListTile(
                    leading: Icon(Icons.cancel_outlined, color: Colors.red),
                    title: Text('Cancelar pedido'),
                  ),
                ),
              // --- INICIO DEL CAMBIO ---
              // Solo mostramos la opción de confirmar si el pedido no está ya entregado o cancelado.
              if (order.status == OrderStatus.enProceso || order.status == OrderStatus.llegando)
                const PopupMenuItem<String>(
                  value: 'confirm',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline, color: Colors.green),
                    title: Text('Confirmar entrega'),
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Eliminar del historial'),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
