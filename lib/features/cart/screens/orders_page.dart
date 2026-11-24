import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/shop_icon_button.dart';
import '../../../core/shop_theme.dart';
import '../demo_order.dart';
import '../cart_cubit.dart';
import '../cart_item_labels.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<DemoOrder>> _orders;
  int? _repeating;
  int? _resultIndex;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _orders = context.read<CartCubit>().getOrders();
  }

  Future<void> _repeat(int index, DemoOrder order) async {
    setState(() {
      _repeating = index;
      _resultIndex = null;
    });
    final added = await context.read<CartCubit>().repeatOrder(order);
    if (!mounted) return;
    setState(() {
      _repeating = null;
      _resultIndex = index;
      _added = added;
    });
  }

  Future<void> _openCart() async {
    await Navigator.pushNamed(context, '/cart');
    if (!mounted) return;
    setState(() {
      _resultIndex = null;
      _orders = context.read<CartCubit>().getOrders();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const ShopBackButton(),
      title: const Text('Мои заказы'),
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: FutureBuilder<List<DemoOrder>>(
            future: _orders,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _message(
                  'Не удалось загрузить заказы.',
                  'Повторить',
                  () {
                    setState(
                      () => _orders = context.read<CartCubit>().getOrders(),
                    );
                  },
                );
              }
              final orders = snapshot.data;
              if (orders == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Загрузка заказов',
                  ),
                );
              }
              if (orders.isEmpty) {
                return _message(
                  'У вас пока нет заказов.',
                  'Перейти к меню',
                  () => Navigator.maybePop(context),
                );
              }
              final localizations = MaterialLocalizations.of(context);
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final date = localizations.formatShortDate(order.placedAt);
                  final time = localizations.formatTimeOfDay(
                    TimeOfDay.fromDateTime(order.placedAt),
                  );
                  return ExpansionTile(
                    key: PageStorageKey(index),
                    title: Text('Демозаказ · $date, $time'),
                    subtitle: Text('Итого: ${formatShopPrice(order.total)}'),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (order.paymentMethod case final method?)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('Способ оплаты: ${method.label}'),
                        ),
                      for (final item in order.items)
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
                      if (_resultIndex == index) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _added
                                ? 'Напитки добавлены в корзину по текущим ценам.'
                                : 'Не удалось повторить заказ. Проверьте меню и попробуйте снова.',
                          ),
                        ),
                        if (_added)
                          TextButton(
                            onPressed: _openCart,
                            child: const Text('Открыть корзину'),
                          ),
                      ],
                      OutlinedButton(
                        onPressed: _repeating == null
                            ? () => _repeat(index, order)
                            : null,
                        child: Text(
                          _repeating == index
                              ? 'Добавляем…'
                              : 'Повторить заказ',
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _message(String message, String action, VoidCallback onPressed) =>
      Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onPressed, child: Text(action)),
            ],
          ),
        ),
      );
}
