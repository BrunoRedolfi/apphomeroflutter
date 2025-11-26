import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_homero/data/repositories/auth_repository_impl.dart';
import 'package:proyecto_homero/data/repositories/order_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_homero/data/datasources/beer_remote_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_homero/domain/repositories/auth_repository.dart';
import 'package:proyecto_homero/domain/repositories/order_repository.dart';
import 'package:proyecto_homero/presentation/blocs/auth/auth_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/beer_counter/beer_counter_bloc.dart';
import 'package:proyecto_homero/presentation/blocs/orders/orders_bloc.dart';
import 'package:proyecto_homero/presentation/services/notification_service.dart';
import 'package:proyecto_homero/presentation/services/settings_service.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/cart/cart_event.dart';
import 'data/repositories/beer_repository_impl.dart';
import 'domain/repositories/beer_repository.dart';
import 'presentation/screens/settings_page.dart';
import 'presentation/screens/beer_menu_screen.dart';
import 'presentation/screens/orders_page.dart';
import 'firebase_options.dart';
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
    // Usamos MultiRepositoryProvider para proveer varios repositorios
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BeerRepository>(
          create: (context) => BeerRepositoryImpl(
            remoteDataSource: BeerRemoteDataSourceImpl(
              firestore: FirebaseFirestore.instance,
            ),
          ),
        ),
        RepositoryProvider<OrderRepository>(
          create: (context) => OrderRepositoryImpl(firestore: FirebaseFirestore.instance),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthAnonymousSignInRequested()), // Solicitamos el login anónimo al inicio
          ),
          BlocProvider(
            create: (context) => CartBloc(
              beerRepository: context.read<BeerRepository>(),
            )..add(CartProductsLoaded()),
          ),
          BlocProvider(create: (context) => BeerCounterBloc()),
          // Añadimos el OrdersBloc aquí para que esté disponible en toda la app
          BlocProvider(
            create: (context) => OrdersBloc(
              orderRepository: context.read<OrderRepository>(),
              authBloc: context.read<AuthBloc>(),
              cartBloc: context.read<CartBloc>(),
            ),
          ),
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

class AdaptiveNavigationScaffold extends StatefulWidget {
  const AdaptiveNavigationScaffold({super.key});

  @override
  State<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends State<AdaptiveNavigationScaffold> {
  // MEJORA: La lista de navegación ahora es parte del estado del widget.
  static const List<AppNavItem> _navItems = [
    AppNavItem(icon: Icons.local_bar, label: 'Menú Duff', page: BeerMenuScreen()),
    AppNavItem(icon: Icons.receipt_long, label: 'Pedidos', page: OrdersPage()),
    AppNavItem(icon: Icons.star, label: 'Extras', page: ExtrasPage()),
    AppNavItem(icon: Icons.settings, label: 'Configuración', page: SettingsPage()),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].label),
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
              destinations: _navItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
          Expanded(child: _navItems[_selectedIndex].page),
        ],
      ),
      bottomNavigationBar: isCompact
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: _navItems
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
