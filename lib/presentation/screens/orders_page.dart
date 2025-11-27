import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_homero/domain/entities/beer.dart';import 'package:proyecto_homero/presentation/blocs/cart/cart_bloc.dart';import 'package:proyecto_homero/presentation/blocs/cart/cart_state.dart';
import '../../domain/entities/favorite_order.dart';
import '../blocs/beer_counter/beer_counter_bloc.dart';
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
              final order = entry.value;
              final index = entry.key;
              // Si el pedido está en proceso, muestra el timer. Si no, la tarjeta normal.
              if (order.status == OrderStatus.enProceso || order.status == OrderStatus.llegando) {
                return OrderTimerCard(order: order, index: index);
              } else {
                return _buildOrderCard(context, order, index);
              }
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
              child: IconButton(
                icon: const Icon(Icons.wallet_outlined, size: 60, color: Colors.black54),
                onPressed: () => _showPaymentDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.yellow[400],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- SECCIÓN PAGAR AHORA ---
              const Text("PAGAR AHORA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.credit_card, size: 60, color: Colors.black54),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<OrdersBloc>().add(OrderConfirmed());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Pagado con tarjeta!'), backgroundColor: Colors.green),
                  );
                },
              ),
              const Divider(height: 30, thickness: 2),
              // --- SECCIÓN PAGAR LUEGO ---
              const Text("PAGAR LUEGO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.payments_outlined, size: 60, color: Colors.black54),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<OrdersBloc>().add(OrderConfirmed());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Anotado! Pagarás en efectivo.'), backgroundColor: Colors.blue),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.credit_card, size: 60, color: Colors.black54),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<OrdersBloc>().add(OrderConfirmed());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Anotado! Pagarás con tarjeta después.'), backgroundColor: Colors.blue),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

// --- NUEVO WIDGET CON ESTADO PARA EL TEMPORIZADOR DEL PEDIDO ---
class OrderTimerCard extends StatefulWidget {
  final Order order;
  final int index;

  const OrderTimerCard({super.key, required this.order, required this.index});

  @override
  State<OrderTimerCard> createState() => _OrderTimerCardState();
}

class _OrderTimerCardState extends State<OrderTimerCard> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final endTime = widget.order.date.add(const Duration(minutes: 5));
    _remainingTime = endTime.difference(DateTime.now());

    if (_remainingTime.isNegative) {
      // Si el tiempo ya pasó, marcamos como entregado inmediatamente.
      _onTimerFinish();
    } else {
      // Si no, iniciamos un timer que se actualiza cada segundo.
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingTime = endTime.difference(DateTime.now());
        });

        if (_remainingTime.isNegative) {
          _onTimerFinish();
        }
      });
    }
  }

  void _onTimerFinish() {
    _timer?.cancel();
    // Solo reproduce el sonido si está activado en la configuración
    if (context.read<BeerCounterBloc>().state.isWoohooSoundEnabled) {
      final player = AudioPlayer();
      // Asegúrate de tener este archivo en assets/sounds/
      player.play(AssetSource('sounds/woohoo.mp3'));
    }

    // Actualiza el estado del pedido a 'entregado'
    context.read<OrdersBloc>().add(OrderStatusChanged(widget.order.id, OrderStatus.entregado));
  }

  @override
  void dispose() {
    _timer?.cancel(); // Es crucial cancelar el timer para evitar memory leaks.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Card(
      color: Colors.yellow[400],
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.delivery_dining, color: Colors.blueAccent, size: 40),
        title: Text(
          'Pedido #${widget.index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Text('🍺x${widget.order.totalItems} - Llegando...'),
        trailing: Text(
          '$minutes:$seconds',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace', // Para que los números no "salten"
          ),
        ),
      ),
    );
  }
}
