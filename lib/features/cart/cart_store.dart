import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../shop/drink.dart';
import '../shop/drink_catalog.dart';
import '../shop/drink_options.dart';
import 'cart_item.dart';
import 'demo_order.dart';

class CartStore {
  CartStore(this._preferences, this._catalog);

  static const _cartKey = 'CART_ITEMS_JSON';
  static const _currency = 'RUB';
  static const _legacyDemoRate = 50;

  final SharedPreferences _preferences;
  final DrinkCatalog _catalog;

  Future<void> saveCartItems(List<CartItem> items) {
    return _write({
      ..._read(),
      'items': [for (final item in items) _model(item).toJson()],
    });
  }

  Future<List<CartItem>> getCartItems() async {
    final models = (_read()['items'] as List)
        .cast<Map<String, dynamic>>()
        .map(_SavedCartItem.fromJson)
        .toList();
    if (models.isEmpty) return [];

    final drinks = await _drinksByName();
    return [
      for (final model in models)
        if (drinks[model.drinkName] case final drink? when model.quantity > 0)
          CartItem(
            drink: drink,
            quantity: model.quantity,
            options: model.options,
          ),
    ];
  }

  _SavedCartItem _model(CartItem item) => _SavedCartItem(
    drinkName: item.drink.name,
    quantity: item.quantity,
    options: item.options,
  );

  Future<void> saveOrder(DemoOrder order) => _write({
    'items': [],
    'orders': [
      {
        'placedAt': order.placedAt.toUtc().toIso8601String(),
        'currency': _currency,
        if (order.paymentMethod case final method?)
          'paymentMethod': method.name,
        'items': [
          for (final item in order.items)
            {
              ..._model(item).toJson(),
              'displayName': item.drink.displayName,
              'unitPrice': item.unitPrice,
            },
        ],
      },
      ..._orders(),
    ],
  });

  Future<List<DemoOrder>> getOrders() async => [
    for (final order in _orders())
      DemoOrder(
        placedAt: DateTime.parse(order['placedAt'] as String).toLocal(),
        paymentMethod: DemoPaymentMethod.values
            .where((method) => method.name == order['paymentMethod'])
            .firstOrNull,
        items: List.unmodifiable(
          (order['items'] as List).cast<Map<String, dynamic>>().map(
            (item) => _readOrderItem(item, order['currency'] == _currency),
          ),
        ),
      ),
  ];

  CartItem _readOrderItem(Map<String, dynamic> json, bool inRubles) {
    final model = _SavedCartItem.fromJson(json);
    final storedPrice = (json['unitPrice'] as num).toDouble();
    final price = inRubles
        ? storedPrice
        : (storedPrice * _legacyDemoRate).roundToDouble();
    return CartItem(
      drink: Drink(
        name: model.drinkName,
        displayName: json['displayName'] as String,
        price: price,
        description: '',
        imagePath: '',
      ),
      quantity: model.quantity,
      options: model.options,
      recordedUnitPrice: price,
    );
  }

  Future<List<CartItem>> getReorderItems(DemoOrder order) async {
    final drinks = await _drinksByName();
    return [
      for (final item in order.items)
        CartItem(
          drink:
              drinks[item.drink.name] ??
              (throw StateError('Напиток недоступен')),
          quantity: item.quantity,
          options: item.options,
        ),
    ];
  }

  Future<Map<String, Drink>> _drinksByName() async => {
    for (final drink in await _catalog.load()) drink.name: drink,
  };

  List<Map<String, dynamic>> _orders() =>
      (_read()['orders'] as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _read() {
    final raw = _preferences.getString(_cartKey);
    final data = raw == null ? [] : jsonDecode(raw);
    if (data is List) return {'items': data, 'orders': []};
    return data as Map<String, dynamic>;
  }

  Future<void> _write(Map<String, dynamic> data) async {
    try {
      if (await _preferences.setString(_cartKey, jsonEncode(data))) return;
    } catch (_) {
      await _preferences.reload();
      rethrow;
    }
    await _preferences.reload();
    throw StateError('Не удалось сохранить корзину');
  }
}

class _SavedCartItem {
  final String drinkName; // в качестве ключа используем уникальное имя напитка
  final int quantity;
  final DrinkOptions options;

  _SavedCartItem({
    required this.drinkName,
    required this.quantity,
    this.options = const DrinkOptions(),
  });

  factory _SavedCartItem.fromJson(Map<String, dynamic> json) {
    return _SavedCartItem(
      drinkName: json['drinkName'] as String,
      quantity: json['quantity'] as int,
      options: DrinkOptions(
        size: _option(DrinkSize.values, json['size']),
        ice: _option(DrinkIce.values, json['ice']),
        sweetness: _option(DrinkSweetness.values, json['sweetness']),
        topping: _option(DrinkTopping.values, json['topping']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drinkName': drinkName,
      'quantity': quantity,
      'size': options.size.name,
      'ice': options.ice.name,
      'sweetness': options.sweetness.name,
      'topping': options.topping.name,
    };
  }

  static T _option<T extends Enum>(List<T> values, Object? name) => values
      .firstWhere((option) => option.name == name, orElse: () => values.first);
}
