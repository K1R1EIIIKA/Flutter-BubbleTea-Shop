import 'package:flutter/material.dart';

import '../cart/cart_controller.dart';
import '../cart/cart_page.dart';

class DrinkDetailPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final String description;
  final String price;

  const DrinkDetailPage({
    super.key,
    required this.imagePath,
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    double numericPrice = double.tryParse(price.replaceAll('\$', '')) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2D8B0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF5D3A00)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Image.network(imagePath, width: 180),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D3A00),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5D3A00),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9E7F62),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  CartController().addItem(
                    CartItem(
                      imagePath: imagePath,
                      name: name,
                      description: description,
                      price: numericPrice,
                    ), // передаём флаг что добавили
                  );
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  'Add to cart',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFF2D8B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
