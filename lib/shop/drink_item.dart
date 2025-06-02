import 'package:flutter/material.dart';

import 'drink_detail_page.dart';

class DrinkItem extends StatelessWidget {
  final String imagePath;
  final String name;
  final String description;
  final String price;

  const DrinkItem({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DrinkDetailPage(imagePath: imagePath, name: name, description: description, price: price),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Image.network(imagePath, width: 70),
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
            const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF5D3A00),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
