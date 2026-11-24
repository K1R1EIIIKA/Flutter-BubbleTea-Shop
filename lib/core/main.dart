import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/cart/presentation/bloc/cart_cubit.dart';
import '../features/cart/presentation/bloc/cart_state.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/cart/presentation/pages/orders_page.dart';
import '../features/shop/presentation/bloc/drink_notes_cubit.dart';
import '../features/shop/presentation/bloc/shop_cubit.dart';
import '../features/shop/presentation/pages/news_page.dart';
import '../features/shop/presentation/pages/shop_page.dart';
import '../firebase_options.dart';
import 'di/injection_container.dart' as di;
import 'screen_log_observer.dart';
import 'shop_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(
    useAndroidCatalog:
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>(create: (_) => di.sl<CartCubit>()..load()),
        BlocProvider<ShopCubit>(
          create: (_) => di.sl<ShopCubit>()..loadDrinks(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..checkLoggedIn(),
        ),
        if (di.sl.isRegistered<DrinkNotesCubit>())
          BlocProvider<DrinkNotesCubit>(
            create: (_) => di.sl<DrinkNotesCubit>()..load(),
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
