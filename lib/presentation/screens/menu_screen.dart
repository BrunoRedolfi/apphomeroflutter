import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../../domain/entities/product.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.brown),
          );
        }
        if (state is CartLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final crossAxisCount = isWide ? 2 : 1;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 1.2 : 1.0,
                ),
                itemCount: state.catalog.length,
                itemBuilder: (context, index) {
                  final productFromCatalog = state.catalog[index];

                  final cartItem = state.cartItems.firstWhere(
                    (item) => item.id == productFromCatalog.id,
                    orElse: () => productFromCatalog.copyWith(quantity: 0),
                  );

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: cartItem.quantity == 0
                        ? _buildInitialCard(context, productFromCatalog)
                        : _buildActiveCard(context, cartItem),
                  );
                },
              );
            },
          );
        }
        if (state is CartError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Algo salió mal.'));
      },
    );
  }

  void _showHomerFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.yellow[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildInitialCard(BuildContext context, Product beer) {
    return Card(
      key: ValueKey('${beer.name}_initial'),
      color: Colors.yellow[100],
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => context.read<CartBloc>().add(CartItemAdded(beer)),
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                beer.image,
                fit: BoxFit.cover,
                width: double.infinity,
                // Muestra un indicador de carga mientras la imagen se descarga
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                },
                // Muestra un icono si hay un error al cargar la imagen
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.no_photography,
                    color: Colors.red,
                    size: 50,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                beer.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context, Product beer) {
    return Card(
      key: ValueKey('${beer.name}_active'),
      color: Colors.yellow[100],
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Image.network(
                  beer.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.brown),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.no_photography,
                      color: Colors.red,
                      size: 50,
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Column(
                children: [
                  Text(
                    beer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.yellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.yellow,
                          size: 50,
                        ),
                        onPressed: () =>
                            context.read<CartBloc>().add(CartItemRemoved(beer)),
                      ),
                      Stack(
                        children: <Widget>[
                          Text(
                            beer.quantity.toString(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2.5
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            beer.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.yellow,
                          size: 50,
                        ),
                        onPressed: () {
                          if (beer.quantity < 20) {
                            context.read<CartBloc>().add(CartItemAdded(beer));
                          } else {
                            _showHomerFeedback(
                              context,
                              "¡Suficiente por ahora!",
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
