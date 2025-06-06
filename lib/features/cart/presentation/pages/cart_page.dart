import 'package:flutter/material.dart';
import 'package:labs/features/cart/domain/entities/cart_item_entity.dart';
import 'package:labs/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // При открытии страницы загружаем содержимое корзины
    context.read<CartCubit>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('Корзина пуста'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (ctx, index) {
                      return _CartItemTile(
                        cartItem: state.items[index],
                        onRemove: () {
                          context
                              .read<CartCubit>()
                              .removeDrink(state.items[index].drink);
                        },
                      );
                    },
                  ),
                ),
                _CartTotalBar(totalPrice: state.totalPrice),
              ],
            );
          } else if (state is CartError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          } else {
            // CartInitial (или любое неожиданное)
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

/// Виджет для отображения одной позиции в корзине
class _CartItemTile extends StatelessWidget {
  final CartItemEntity cartItem;
  final VoidCallback onRemove;

  const _CartItemTile({
    Key? key,
    required this.cartItem,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drink = cartItem.drink;
    return ListTile(
      leading: Image.asset(
        drink.imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(drink.name),
      subtitle: Text(
        'Цена: ${drink.price.toStringAsFixed(2)} ₽\n'
            'Количество: ${cartItem.quantity}',
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onRemove,
      ),
    );
  }
}

/// Виджет для отображения итоговой суммы и кнопки оформления
class _CartTotalBar extends StatelessWidget {
  final double totalPrice;

  const _CartTotalBar({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Итого: ${totalPrice.toStringAsFixed(2)} ₽',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Здесь обработать «оформление заказа»
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Переход к оплате…')),
              );
            },
            child: const Text('Оформить заказ'),
          ),
        ],
      ),
    );
  }
}
