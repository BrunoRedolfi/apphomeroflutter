import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/cart/cart_event.dart';
import 'repositories/beer_repository.dart';
import 'screens/settings_page.dart';
import 'screens/beer_menu_screen.dart';
import 'screens/favorites_page.dart';
import 'screens/extras_page.dart';

void main() {
  runApp(const TabernadeMoeApp());
}

class TabernadeMoeApp extends StatelessWidget {
  const TabernadeMoeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => BeerRepository(),
      child: BlocProvider(
        create: (context) => CartBloc(
          beerRepository: context.read<BeerRepository>(),
        )..add(CartProductsLoaded()), // Dispara el evento inicial para cargar productos
        child: MaterialApp(
          title: 'La App de la Taberna de Moe',
          theme: ThemeData(
            primarySwatch: Colors.yellow,
            textTheme: Platform.isIOS
                ? TextTheme(
                    bodyMedium: CupertinoThemeData().textTheme.textStyle.copyWith(
                      fontSize: 16,
                    ),
                  )
                : null,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const AdaptiveNavigationScaffold(),
        ),
      ),
    );
  }
}

class AppNavItem {
  final IconData icon;
  final String label;
  final Widget page;

  const AppNavItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

final List<AppNavItem> mainNavItems = [
  const AppNavItem(icon: Icons.local_bar, label: 'Menú Duff', page: BeerMenuScreen()),
  AppNavItem(icon: Icons.favorite, label: 'Favoritos', page: FavoritesPage()),
  AppNavItem(icon: Icons.star, label: 'Extras', page: ExtrasPage()),
  const AppNavItem(icon: Icons.settings, label: 'Configuración', page: SettingsPage()),
];

class AdaptiveNavigationScaffold extends StatefulWidget {
  const AdaptiveNavigationScaffold({super.key});

  @override
  State<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends State<AdaptiveNavigationScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(mainNavItems[_selectedIndex].label),
        backgroundColor: Colors.yellow[800],
        foregroundColor: Colors.black,
      ),
      body: Row(
        children: [
          if (!isCompact)
            NavigationRail(
              backgroundColor: Colors.yellow[700],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              destinations: mainNavItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
          Expanded(child: mainNavItems[_selectedIndex].page),
        ],
      ),
      bottomNavigationBar: isCompact
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: mainNavItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
              selectedItemColor: Colors.black,
              backgroundColor: Colors.yellow[700],
            )
          : null,
    );
  }
}