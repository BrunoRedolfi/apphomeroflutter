import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/favorite_order.dart';
import '../../domain/entities/order.dart';
import '../blocs/orders/orders_bloc.dart';
import '../blocs/orders/orders_event.dart';
import '../blocs/orders/orders_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El AppBar ahora es manejado por AdaptiveNavigationScaffold en main.dart
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersLoadSuccess) {
            return _buildOrdersList(context, state);
          } else if (state is OrdersError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("Algo salió mal."));
          }
        },
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, OrdersLoadSuccess state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('Favoritos'),
        ...state.favoriteOrders.map((fav) => _buildFavoriteCard(context, fav)),
        const SizedBox(height: 24),
        _buildSectionTitle('Pedidos'),
        ...state.activeOrders.map((order) => _buildOrderCard(context, order)),
      ],
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
        leading: CircleAvatar(
          backgroundColor: Colors.yellow[700],
          child: Text(
            '#${favorite.id}',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        title: const Text('Pedido Favorito'),
        subtitle: Text('${favorite.totalItems} productos'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showFavoriteDrawer(context, favorite),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showOrderDrawer(context, order),
      ),
    );
  }

  void _showFavoriteDrawer(BuildContext context, FavoriteOrder favorite) {
    Scaffold.of(context).openEndDrawer();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              builder: (_, controller) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Favorito #${favorite.id}', style: Theme.of(context).textTheme.headlineSmall),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: favorite.items.length,
                        itemBuilder: (c, i) => ListTile(
                          title: Text(favorite.items[i].name),
                          trailing: Text('x${favorite.items[i].quantity}'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.repeat),
                        label: const Text('Repetir Pedido'),
                        onPressed: () {
                          context.read<OrdersBloc>().add(OrderRepeated(favorite));
                          Navigator.of(ctx).pop(); // Cierra el bottom sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pedido añadido a la lista!'), backgroundColor: Colors.green),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ));
        });
  }

  void _showOrderDrawer(BuildContext context, Order order) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              builder: (_, controller) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Detalles del Pedido', style: Theme.of(context).textTheme.headlineSmall),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: order.items.length,
                        itemBuilder: (c, i) => ListTile(
                          title: Text(order.items[i].name),
                          trailing: Text('x${order.items[i].quantity}'),
                        ),
                      ),
                    ),
                    const Divider(),
                    Text('Estado: ${order.statusText}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Cancelar Pedido'),
                          onPressed: order.status == OrderStatus.cancelado ? null : () {
                            context.read<OrdersBloc>().add(OrderStatusChanged(order.id, OrderStatus.cancelado));
                            Navigator.of(ctx).pop();
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Confirmar Entrega'),
                          onPressed: order.status == OrderStatus.entregado ? null : () {
                             context.read<OrdersBloc>().add(OrderStatusChanged(order.id, OrderStatus.entregado));
                             Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ));
        });
  }
}
