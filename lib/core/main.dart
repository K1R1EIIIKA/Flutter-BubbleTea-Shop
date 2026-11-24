import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/auth_cubit.dart';
import '../features/auth/auth_store.dart';
import '../features/auth/screens/login_page.dart';
import '../features/auth/screens/profile_page.dart';
import '../features/auth/screens/register_page.dart';
import '../features/cart/cart_cubit.dart';
import '../features/cart/cart_store.dart';
import '../features/cart/screens/cart_page.dart';
import '../features/cart/screens/orders_page.dart';
import '../features/shop/android_catalog.dart';
import '../features/shop/drink_catalog.dart';
import '../features/shop/drink_notes_cubit.dart';
import '../features/shop/screens/news_page.dart';
import '../features/shop/screens/shop_page.dart';
import '../features/shop/shop_cubit.dart';
import '../firebase_options.dart';
import 'screen_log_observer.dart';
import 'shop_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final androidCatalog =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? AndroidCatalog()
      : null;
  final catalog = DrinkCatalog(readCachedCatalog: androidCatalog?.readCatalog);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MyApp(
      catalog: catalog,
      cartStore: CartStore(preferences, catalog),
      authStore: AuthStore(preferences),
      androidCatalog: androidCatalog,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.catalog,
    required this.cartStore,
    required this.authStore,
    this.androidCatalog,
  });

  final DrinkCatalog catalog;
  final CartStore cartStore;
  final AuthStore authStore;
  final AndroidCatalog? androidCatalog;

  @override
  Widget build(BuildContext context) {
    final android = androidCatalog;
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>(create: (_) => CartCubit(cartStore)..load()),
        BlocProvider<ShopCubit>(
          create: (_) => ShopCubit(
            catalog: catalog,
            refreshCatalog: android?.refreshCatalog,
            catalogChanges: android?.catalogChanges,
          )..loadDrinks(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authStore)..checkLoggedIn(),
        ),
        if (android != null)
          BlocProvider<DrinkNotesCubit>(
            create: (_) => DrinkNotesCubit(android)..load(),
          ),
      ],
      child: MaterialApp(
        title: 'Biba & Boba',
        theme: shopTheme,
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [ScreenLogObserver()],
        routes: {
          '/': (_) => const MainPage(),
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/shop': (_) => const MainPage(),
          '/cart': (_) => const MainPage(initialIndex: 1),
          '/orders': (_) => const OrdersPage(),
          '/profile': (_) => const ProfilePage(),
          '/news': (_) => const NewsPage(),
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex = widget.initialIndex;

  void _select(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final count = context.select((CartCubit cubit) {
      final state = cubit.state;
      return state is CartLoaded ? state.itemCount : 0;
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ShopPage(),
          CartPage(onBrowse: () => _select(0)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: shopSurface,
        indicatorColor: shopDivider,
        selectedIndex: _currentIndex,
        onDestinationSelected: _select,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.local_drink_outlined),
            selectedIcon: Icon(Icons.local_drink),
            label: 'Меню',
          ),
          NavigationDestination(
            icon: Semantics(
              label: 'Напитков: $count',
              child: Badge(
                isLabelVisible: count > 0,
                label: ExcludeSemantics(
                  child: Text(count > 99 ? '99+' : '$count'),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            label: 'Корзина',
            tooltip: 'Корзина. Напитков: $count',
          ),
        ],
      ),
    );
  }
}
