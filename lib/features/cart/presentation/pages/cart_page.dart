import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:labs/features/cart/domain/entities/cart_item_entity.dart';
import 'package:labs/features/cart/presentation/bloc/cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCE5CC);
    final brown = const Color(0xFF7A4F23);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          'Cart',
          style: TextStyle(color: Color(0xFF7A4F23), fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            final items = state.items;
            final total = state.totalPrice;

            if (items.isEmpty) {
              return const Center(child: Text('Корзина пуста'));
            }

            return Column(
              children: [
                ...items.map((cartItem) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Image.asset(cartItem.drink.imagePath, height: 60),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          cartItem.drink.name,
                          style: const TextStyle(
                            color: Color(0xFF7A4F23),
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.read<CartCubit>().removeDrink(cartItem.drink),
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Color(0xFF7A4F23), size: 24),
                      ),
                      Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF7A4F23),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.read<CartCubit>().addDrink(cartItem.drink),
                        icon: const Icon(Icons.add_circle_outline,
                            color: Color(0xFF7A4F23), size: 24),
                      ),
                      Text(
                        '\$${(cartItem.drink.price * cartItem.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF7A4F23),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )),
                const Spacer(),
                const Divider(height: 1, thickness: 1, color: Color(0xFFDCC3A4)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFFBCA47C),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF7A4F23),
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: ElevatedButton(
                    onPressed: items.isNotEmpty ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(220, 52),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            );
          } else if (state is CartError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
