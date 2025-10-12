import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Favoritos (pedidos guardados)
class FavoritesPage extends StatelessWidget {
  final List<String> favorites = [
    '12 Donuts + 6 Cervezas + Nachos Gigantes',
    '20 Duff Light',
  ];

  FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          color: Colors.brown[200],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              favorites[index],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
