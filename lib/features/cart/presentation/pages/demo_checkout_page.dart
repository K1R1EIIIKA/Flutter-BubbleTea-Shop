import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shop_icon_button.dart';
import '../../../../core/shop_theme.dart';
import '../../domain/entities/demo_order.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../cart_item_labels.dart';

class DemoCheckoutPage extends StatefulWidget {
  const DemoCheckoutPage({super.key});

  @override
  State<DemoCheckoutPage> createState() => _DemoCheckoutPageState();
}

class _DemoCheckoutPageState extends State<DemoCheckoutPage> {
  CartLoaded? _confirmed;
  bool _submitting = false;
  bool _failed = false;
  DemoPaymentMethod _payment = DemoPaymentMethod.card;

  Future<void> _confirm(CartLoaded cart) async {
    setState(() {
      _submitting = true;
      _failed = false;
    });
    final saved = await context.read<CartCubit>().placeDemoOrder(
      cart,
      paymentMethod: _payment,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _failed = !saved;
      if (saved) _confirmed = cart;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CartCubit>().state;
    final confirmed = _confirmed;
    final cart = confirmed ?? (state is CartLoaded ? state : null);

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(
          leading: const ShopBackButton(),
          title: const Text('Демозаказ'),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                key: ValueKey(confirmed != null),
                padding: const EdgeInsets.all(24),
                children: [
                  if (confirmed != null)
                    Semantics(
                      liveRegion: true,
                      header: true,
                      child: Text(
                        'Демозаказ оформлен',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  const Text('Демонстрационный режим. Оплата не списывается.'),
                  if (cart != null && cart.items.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    for (final item in cart.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.drink.displayName} × ${item.quantity} · ${formatShopPrice(item.lineTotal)}',
                            ),
                            Text(
                              cartItemOptions(item),
                              style: const TextStyle(color: shopMuted),
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                    Text(
                      'Итого: ${formatShopPrice(cart.totalPrice)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                  if (_failed)
                    Semantics(
                      liveRegion: true,
                      child: const Text(
                        'Не удалось оформить демозаказ. Проверьте корзину и повторите.',
                      ),
                    ),
                  if (confirmed != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Способ оплаты: ${_payment.label}'),
                    )
                  else if (cart != null && cart.items.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Semantics(
                      header: true,
                      child: Text(
                        'Способ оплаты',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final method in DemoPaymentMethod.values)
                      RadioListTile<DemoPaymentMethod>(
                        contentPadding: EdgeInsets.zero,
                        value: method,
                        groupValue: _payment,
                        onChanged: _submitting
                            ? null
                            : (value) => setState(() => _payment = value!),
                        title: Text(method.label),
                      ),
                  ],
                  const SizedBox(height: 24),
                  if (confirmed != null) ...[
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Перейти к меню'),
                    ),
                  ] else if (cart != null && cart.items.isNotEmpty)
                    FilledButton(
                      onPressed: _submitting ? null : () => _confirm(cart),
                      child: Text(
                        _submitting ? 'Оформляем…' : 'Подтвердить демозаказ',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
