import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/core/di/injection_container.dart' as di;
import 'package:labs/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:labs/features/auth/presentation/pages/login_page.dart';
import 'package:labs/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:labs/features/shop/presentation/bloc/shop_cubit.dart';
import 'package:labs/features/shop/presentation/pages/shop_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/cart/presentation/pages/cart_page.dart';
import '../features/shop/presentation/pages/drink_detail_page.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('is_logged_in') ?? false;
  final username = prefs.getString('username') ?? '';

  await di.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>(create: (_) => di.sl<CartCubit>()),
        BlocProvider<ShopCubit>(create: (_) => di.sl<ShopCubit>()),
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>()..checkLoggedIn(),
        ),
        // если есть
        // BlocProvider<AuthCubit>(create: (_) => di.sl<AuthCubit>()), // и т. д.
      ],
      child: MaterialApp(
        title: 'Ваше приложение',
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Вот тут корневой экран
        routes: {
          '/': (_) => const RootPage(),
          '/login': (_) => const LoginPage(),
          '/cart': (_) => const CartPage(),
          '/shop': (_) => const ShopPage(),
          '/drink_detail': (_) => const DrinkDetailPage(),
          // '/login': (_) => const LoginPage(),
          // … остальные маршруты
        },
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainPage();
        } else if (state is AuthInitial || state is AuthError) {
          return const LoginPage();
        } else {
          // loading
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const Color _bgColor = Color(0xFFF2D8B0);
  static const Color _darkerBgColor = Color(0xFFEACDA2);

  List<Widget> get _pages => [const ShopPage(), const CartPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.indigo,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: const Text(
                  'Меню',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: _darkerBgColor,
        activeColor: const Color(0xFF5D3A00),
        inactiveColor: const Color(0xFF9E7F62),
        iconSize: 30,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart_fill),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart_fill_badge_plus),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
