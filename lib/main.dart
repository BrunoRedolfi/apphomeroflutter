import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_homero/data/datasources/beer_remote_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/beer_counter/beer_counter_bloc.dart';
import 'package:proyecto_homero/presentation/services/notification_service.dart';
import 'package:proyecto_homero/presentation/services/settings_service.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/cart/cart_event.dart';
import 'data/repositories/beer_repository_impl.dart';
import 'domain/repositories/beer_repository.dart';
import 'presentation/screens/settings_page.dart';
import 'presentation/screens/beer_menu_screen.dart';
import 'presentation/screens/favorites_page.dart';
import 'presentation/screens/extras_page.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de cualquier otra cosa.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase usando las opciones generadas por FlutterFire CLI.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicializamos nuestro servicio de notificaciones
  await NotificationService().init();

  // Comprobamos si el recordatorio debe estar activo al iniciar
  final settingsService = SettingsService();
  if (await settingsService.getWaterReminder()) {
    await NotificationService().scheduleHourlyWaterReminder();
  }
  runApp(const TabernadeMoeApp());
}

class TabernadeMoeApp extends StatelessWidget {
  const TabernadeMoeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<BeerRepository>(
      create: (context) => BeerRepositoryImpl(
        remoteDataSource: BeerRemoteDataSourceImpl(
          // Le pasamos la instancia de Firestore
          firestore: FirebaseFirestore.instance,
        ),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CartBloc(
              beerRepository: context.read<BeerRepository>(),
            )..add(CartProductsLoaded()),
          ),
          BlocProvider(create: (context) => BeerCounterBloc()),
        ],
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