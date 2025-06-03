import 'package:flutter/material.dart';
import 'package:labs/base/settings.dart';
import 'package:labs/shop/drink_item.dart';
import 'package:labs/utils/json_controller.dart';

import '../models/Drink.dart';

class ShopView extends StatefulWidget {
  const ShopView({Key? key}) : super(key: key);

  @override
  _ShopViewState createState() => _ShopViewState();

  void updateShop() => _ShopViewState().updateShop();
}

class _ShopViewState extends State<ShopView> {
  late Future<List<Drink>> _futureDrinks;

  void updateShop() {
    setState(() {
      _futureDrinks = JsonController().loadFromNetwork<Drink>(
        url:
            'https://my-json-server.typicode.com/K1R1EIIIKA/data_resository/drinks',
        fromJson: (json) => Drink.fromJson(json),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _futureDrinks = JsonController().loadFromNetwork<Drink>(
      url:
          'https://my-json-server.typicode.com/K1R1EIIIKA/data_resository/drinks',
      fromJson: (json) => Drink.fromJson(json),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF2D8B0),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF2D8B0),
            elevation: 0,
            title: const Text(
              'Bubble Tea',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D3A00),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF5D3A00)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsView()),
                  );
                },
              ),
            ],
          ),
          body: FutureBuilder<List<Drink>>(
            future: _futureDrinks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No drinks available'));
              }

              final drinks = snapshot.data!;
              return ListView.builder(
                itemCount: drinks.length,
                itemBuilder: (context, index) {
                  final drink = drinks[index];
                  return DrinkItem(
                    imagePath: drink.imagePath,
                    name: drink.name,
                    description: drink.description,
                    price: drink.price.toStringAsFixed(2),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
