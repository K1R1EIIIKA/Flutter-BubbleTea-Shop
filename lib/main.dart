import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labs/auth/login.dart';
import 'package:labs/shop/shop.dart';
import 'package:labs/shop/cart_controller.dart';
import 'package:labs/cart/cart_page.dart';
import 'package:math_expressions/math_expressions.dart';

import 'calculator.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator with Shop & Home',
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
      ),
      home: const LoginScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  final String username;

  const MainPage({Key? key, required this.username}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const Color _bgColor = Color(0xFFF2D8B0);
  static const Color _darkerBgColor = Color(0xFFEACDA2);

  List<Widget> get _pages => [
    HomeView(username: widget.username),
    const ShopView(),
    CartPage(),
    const CalculatorView(),
  ];

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
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: _currentIndex == 0,
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                  Navigator.of(context).pop();
                },
              ),
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
              ListTile(
                leading: const Icon(CupertinoIcons.cart_fill_badge_plus),
                title: const Text('Cart'),
                selected: _currentIndex == 2,
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.plus_app),
                title: const Text('Calc'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart_fill), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart_fill_badge_plus), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.plus_app_fill), label: 'Calc'),
        ],
      ),
    );
  }
}