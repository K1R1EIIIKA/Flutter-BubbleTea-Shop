import 'package:flutter/material.dart';
import 'package:labs/shop/drink_detail_page.dart';
import 'cart_controller.dart';

class CartItem {
  final String imagePath;
  final String name;
  final String description;
  final double price;

  CartItem({
    required this.imagePath,
    required this.name,
    required this.description,
    required this.price,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> get cartItems => CartController().items;

  double get total => cartItems.fold(0, (sum, item) => sum + item.price);

  void removeItem(int index) {
    setState(() {
      CartController().removeItem(cartItems[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2D8B0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2D8B0),
          elevation: 0,
          title: const Text(
            'Cart',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D3A00),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Cart is empty',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF5D3A00),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DrinkDetailPage(
                                        imagePath: item.imagePath,
                                        name: item.name,
                                        description: item.description,
                                        price: item.price.toStringAsFixed(2),
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    setState(() {}); // обновляем корзину
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.network(item.imagePath, width: 70),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                                color: Color(0xFF5D3A00),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${item.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF5D3A00),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: IconButton(
                                          onPressed: () => removeItem(index),
                                          icon: const Icon(
                                            Icons.close,
                                            size: 28,
                                            color: Color(0xFF5D3A00),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(
                    thickness: 1,
                    color: Color(0x5A5D3A00)
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 20, color: Color(0xFF5D3A00)),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D3A00),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      handleCheckoutPressed();
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D3A00),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF2D8B0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleCheckoutPressed() {
    if (cartItems.isEmpty) return;

    setState(() {
      CartController().clear();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(); // автоматически закрыть
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFF2D8B0),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF5D3A00), size: 48),
                SizedBox(height: 16),
                Text(
                  'Покупка совершена!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D3A00),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
