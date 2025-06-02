import 'package:flutter/material.dart';

class ShopView extends StatelessWidget {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF2D8B0),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bubble Tea',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D3A00),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  DrinkItem(
                    imagePath: 'assets/img/tea/strawberry_cactus.png',
                    name: 'Strawberry & Cactus',
                    price: '\$6.99',
                  ),
                  DrinkItem(
                    imagePath: 'assets/img/tea/mango.png',
                    name: 'Mango',
                    price: '\$6.99',
                  ),
                  DrinkItem(
                    imagePath: 'assets/img/tea/blue_matcha.png',
                    name: 'Blue Matcha',
                    price: '\$6.99',
                  ),
                  DrinkItem(
                    imagePath: 'assets/img/tea/caramel.png',
                    name: 'Caramel',
                    price: '\$6.99',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrinkItem extends StatelessWidget {
  final String imagePath;
  final String name;
  final String price;

  const DrinkItem({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Image.asset(imagePath, width: 70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF5D3A00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D3A00),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.shopping_bag_outlined, color: Color(0xFF5D3A00), size: 28),
        ],
      ),
    );
  }
}
