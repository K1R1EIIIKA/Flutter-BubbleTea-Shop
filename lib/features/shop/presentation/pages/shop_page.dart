import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/auth/presentation/bloc/auth_cubit.dart';

import '../bloc/shop_cubit.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShopCubit>().loadDrinks();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    String greeting = '';
    if (authState is AuthAuthenticated) {
      greeting = 'Привет, ${authState.user.username}!';
    }

    return Scaffold(
      backgroundColor: Color(0xFFF2D8B0),
      appBar: AppBar(
        title: Text(greeting.isEmpty ? 'Магазин' : greeting),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Настройки',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Настройки'),
                  content: const Text('Выйти из аккаунта?'),
                  actions: [
                    TextButton(
                      child: const Text('Отмена'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Выйти'),
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: BlocBuilder<ShopCubit, ShopState>(
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShopLoaded) {
            return ListView.builder(
              itemCount: state.drinks.length,
              itemBuilder: (context, index) {
                final drink = state.drinks[index];
                return ListTile(
                  leading: Image.asset(drink.imagePath, width: 50, height: 50),
                  title: Text(drink.name),
                  subtitle: Text('${drink.price.toStringAsFixed(2)} ₽'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/drink_detail',
                      arguments: drink,
                    );
                  },
                );
              },
            );
          } else if (state is ShopError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
