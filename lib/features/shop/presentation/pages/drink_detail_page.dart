import 'package:flutter/material.dart';
import '../../domain/entities/drink_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';

class DrinkDetailPage extends StatelessWidget {
  const DrinkDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DrinkEntity drink = ModalRoute.of(context)!.settings.arguments as DrinkEntity;

    return Scaffold(
      appBar: AppBar(title: Text(drink.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(drink.imagePath, height: 200),
            const SizedBox(height: 16),
            Text(drink.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Цена: ${drink.price.toStringAsFixed(2)} ₽', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartCubit>().addDrink(drink);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Добавлено в корзину')));
                },
                child: const Text('Добавить в корзину'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
