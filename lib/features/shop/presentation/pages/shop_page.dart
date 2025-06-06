import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/shop/presentation/bloc/shop_cubit.dart';
import 'package:labs/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:labs/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:labs/features/shop/domain/entities/drink_entity.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCE5CC);
    final brown = const Color(0xFF7A4F23);

    final authState = context.watch<AuthCubit>().state;
    String greeting = '';
    if (authState is AuthAuthenticated) {
      greeting = 'Hi, ${authState.user.username}!';
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          greeting,
          style: const TextStyle(
            color: Color(0xFF7A4F23),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Color(0xFF7A4F23)),
            tooltip: 'Выйти из аккаунта',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Выйти из аккаунта?'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                context.read<AuthCubit>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
        child: BlocBuilder<ShopCubit, ShopState>(
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ShopLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...state.drinks.map((drink) => Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: Row(
                      children: [
                        Image.asset(drink.imagePath, height: 68),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            drink.name,
                            style: const TextStyle(
                              color: Color(0xFF7A4F23),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '\$${drink.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF7A4F23),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DrinkDetailPage(drink: drink),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag_outlined,
                              size: 30, color: Color(0xFF7A4F23)),
                          tooltip: 'Подробнее',
                        ),
                      ],
                    ),
                  )),
                ],
              );
            } else if (state is ShopError) {
              return Center(child: Text('Ошибка: ${state.message}'));
            }
            return const Center(child: Text('Нет товаров'));
          },
        ),
      ),
    );
  }
}

class DrinkDetailPage extends StatelessWidget {
  final DrinkEntity drink;
  const DrinkDetailPage({Key? key, required this.drink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFCE5CC);
    final brown = const Color(0xFF7A4F23);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF7A4F23)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Image.asset(drink.imagePath, height: 160),
          const SizedBox(height: 18),
          Text(
            drink.name,
            style: const TextStyle(
              color: Color(0xFF7A4F23),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${drink.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF7A4F23),
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              drink.description,
              style: const TextStyle(
                color: Color(0xFFBCA47C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<CartCubit>().addDrink(drink);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${drink.name} добавлен в корзину')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text(
                'Add to cart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
