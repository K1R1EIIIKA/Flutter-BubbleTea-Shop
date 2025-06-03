import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labs/auth/account_manager.dart';
import 'package:labs/auth/login.dart';
import 'package:labs/cart/cart_page.dart';
import 'package:labs/shop/shop.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('is_logged_in') ?? false;
  final username = prefs.getString('username') ?? '';

  if (username.isNotEmpty) {
    AccountManager().username = username;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(MyApp(initialRoute: loggedIn ? 'main' : 'login', username: username));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String username;

  const MyApp({Key? key, required this.initialRoute, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bubble Tea App',
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      home: initialRoute == 'main'
          ? MainPage()
          : const LoginScreen(),
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

  List<Widget> get _pages => [
    const ShopView(),
    const CartPage(),
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
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SettingsView(),
                  ));
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
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart_fill), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart_fill_badge_plus), label: 'Cart'),
        ],
      ),
    );
  }
}