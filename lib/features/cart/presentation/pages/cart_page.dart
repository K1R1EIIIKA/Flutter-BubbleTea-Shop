import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shop_icon_button.dart';
import '../../../../core/shop_theme.dart';
import '../../../shop/presentation/pages/drink_detail_page.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../cart_item_labels.dart';
import 'demo_checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

  void _browse(BuildContext context) {
    if (onBrowse case final browse?) {
      browse();
    } else {
      Navigator.pushReplacementNamed(context, '/shop');
    }
  }

  Future<void> _checkout(BuildContext context) async {
    final browse = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const DemoCheckoutPage()),
    );
    if (browse == true && context.mounted) _browse(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CartCubit>().state;
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: switch (state) {
              CartLoaded(:final items) when items.isNotEmpty =>
                ListView.separated(
                  key: const PageStorageKey('cart'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) => _CartRow(item: items[index]),
                ),
              CartLoaded() => _CartMessage(
                message: 'Корзина пуста',
                action: 'Перейти к меню',
                onPressed: () => _browse(context),
              ),
              CartError(:final message) => _CartMessage(
                message: message,
                action: 'Повторить',
                onPressed: context.read<CartCubit>().load,
              ),
              _ => const CircularProgressIndicator(
                semanticsLabel: 'Загрузка корзины',
              ),
            },
          ),
        ),
      ),
      bottomNavigationBar: switch (state) {
        CartLoaded(:final items) when items.isNotEmpty => DecoratedBox(
          decoration: const BoxDecoration(
            color: shopSurface,
            border: Border(top: BorderSide(color: shopDivider)),
          ),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.saveError case final error?)
                        Semantics(liveRegion: true, child: Text(error)),
                      Text(
                        'Итого: ${formatShopPrice(state.totalPrice)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      FilledButton(
                        onPressed: () => _checkout(context),
                        child: const Text(
                          'Оформить демозаказ',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _ => null,
      },
    );
  }
}

class _CartMessage extends StatelessWidget {
  const _CartMessage({
    required this.message,
    required this.action,
    required this.onPressed,
  });

  final String message;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onPressed, child: Text(action)),
      ],
    ),
  );
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final drink = item.drink;
    final cart = context.read<CartCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                drink.imagePath,
                width: 48,
                height: 56,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      cartItemOptions(item),
                      style: const TextStyle(color: shopMuted),
                    ),
                  ],
                ),
              ),
              ShopIconButton(
                label: 'Изменить напиток: ${cartItemActionLabel(item)}',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DrinkDetailPage.edit(item: item),
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ShopIconButton(
                label: 'Уменьшить количество: ${cartItemActionLabel(item)}',
                onPressed: () => cart.removeDrink(drink, options: item.options),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Semantics(
                label: 'Количество: ${item.quantity}',
                excludeSemantics: true,
                child: Text('${item.quantity}'),
              ),
              ShopIconButton(
                label: 'Увеличить количество: ${cartItemActionLabel(item)}',
                onPressed: () => cart.addDrink(drink, options: item.options),
                icon: const Icon(Icons.add_circle_outline),
              ),
              Text(
                formatShopPrice(item.lineTotal),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
