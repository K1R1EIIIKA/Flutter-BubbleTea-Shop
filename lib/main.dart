import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labs/login.dart';
import 'package:labs/shop.dart';
import 'package:math_expressions/math_expressions.dart';

// Импортируем только что созданный файл home.dart
import 'calculator.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

/// MyApp — точка входа в приложение.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator with Shop & Home',
      theme: ThemeData(
        // Убираем ripple-эффекты из кнопок, чтобы калькулятор вел себя
        // как в предыдущем макете (без лишних splash-эффектов).
        splashFactory: NoSplash.splashFactory,
      ),
      home: const MainPage(),
    );
  }
}

/// MainPage — это Scaffold с Drawer (слева) и IndexedStack (тело).
/// Нижняя панель (CupertinoTabBar) отображается только при переходе на Shop или Calc.
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// 0 → Home, 1 → Shop, 2 → Calculator
  int _currentIndex = 0;

  static const Color _bgColor = Color(0xFFF2D8B0);

  /// Псевдо-список: HomeView, ShopView, CalculatorView
  final List<Widget> _pages = const [
    HomeView(),
    ShopView(),
    CalculatorView(),
    LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,

      /// Drawer — выдвигающееся меню слева.
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Простой заголовок
              Container(
                color: Colors.blue.shade700,
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
              const SizedBox(height: 12),

              // Пункт Home
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: _currentIndex == 0,
                onTap: () {
                  // При выборе «Home» переключаемся на index=0
                  setState(() {
                    _currentIndex = 0;
                  });
                  Navigator.of(context).pop(); // Закрываем Drawer
                },
              ),

              // Пункт Shop
              ListTile(
                leading: const Icon(CupertinoIcons.cart),
                title: const Text('Shop'),
                selected: _currentIndex == 1,
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                  Navigator.of(context).pop();
                },
              ),

              // Пункт Calc
              ListTile(
                leading: const Icon(CupertinoIcons.plus_app),
                title: const Text('Calc'),
                selected: _currentIndex == 2,
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                  Navigator.of(context).pop();
                },
              ),

              // Пункт Login
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                selected: _currentIndex == 3,
                onTap: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),

      /// Тело страницы: показываем только ту View, чей индекс == _currentIndex.
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: Colors.blue.shade700,
        inactiveColor: Colors.grey.shade600,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart_fill),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_app_fill),
            label: 'Calc',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
        ],
      ),
    );
  }
}
