import 'dart:async';
import 'package:labs/features/shop/domain/entities/drink_entity.dart';
import 'package:labs/features/shop/domain/repositories/drink_repository.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/demo_order.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

/// Реализация CartRepository, которая использует локальный DataSource
/// и DrinkRepository, чтобы собрать полные DrinkEntity по имени.
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final DrinkRepository drinkRepository;
  static const _currency = 'RUB';
  static const _legacyDemoRate = 50;

  CartRepositoryImpl({
    required this.localDataSource,
    required this.drinkRepository,
  });

  @override
  Future<void> addToCart(DrinkEntity drink) async {
    // Сначала получаем текущий список моделей
    final models = await localDataSource.getCartItems();

    // Проверяем, есть ли уже элемент с этим drink.name
    final defaultItem = CartItemModel(drinkName: drink.name, quantity: 1);
    final index = models.indexWhere(
      (m) => m.drinkName == drink.name && m.options == defaultItem.options,
    );
    if (index >= 0) {
      // Если есть, увеличиваем quantity
      final existing = models[index];
      models[index] = CartItemModel(
        drinkName: existing.drinkName,
        quantity: existing.quantity + 1,
        options: existing.options,
      );
    } else {
      // Иначе добавляем новый
      models.add(defaultItem);
    }

    // Сохраняем обновлённый список обратно
    await localDataSource.saveCartItems(models);
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) {
    return localDataSource.saveCartItems([
      for (final item in items) _model(item),
    ]);
  }

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final models = await localDataSource.getCartItems();
    if (models.isEmpty) return [];

    final drinks = {
      for (final drink in await drinkRepository.getAllDrinks())
        drink.name: drink,
    };
    return [
      for (final model in models)
        if (drinks[model.drinkName] case final drink? when model.quantity > 0)
          CartItemEntity(
            drink: drink,
            quantity: model.quantity,
            options: model.options,
          ),
    ];
  }

  CartItemModel _model(CartItemEntity item) => CartItemModel(
    drinkName: item.drink.name,
    quantity: item.quantity,
    options: item.options,
  );

  @override
  Future<void> saveOrder(DemoOrder order) => localDataSource.saveOrder({
    'placedAt': order.placedAt.toUtc().toIso8601String(),
    'currency': _currency,
    if (order.paymentMethod case final method?) 'paymentMethod': method.name,
    'items': [
      for (final item in order.items)
        {
          ..._model(item).toJson(),
          'displayName': item.drink.displayName,
          'unitPrice': item.unitPrice,
        },
    ],
  });

  @override
  Future<List<DemoOrder>> getOrders() async => [
    for (final order in localDataSource.getOrders())
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

  CartItemEntity _readOrderItem(Map<String, dynamic> json, bool inRubles) {
    final model = CartItemModel.fromJson(json);
    final storedPrice = (json['unitPrice'] as num).toDouble();
    final price = inRubles
        ? storedPrice
        : (storedPrice * _legacyDemoRate).roundToDouble();
    return CartItemEntity(
      drink: DrinkEntity(
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

  @override
  Future<List<CartItemEntity>> getReorderItems(DemoOrder order) async {
    final drinks = {
      for (final drink in await drinkRepository.getAllDrinks())
        drink.name: drink,
    };
    return [
      for (final item in order.items)
        CartItemEntity(
          drink:
              drinks[item.drink.name] ??
              (throw StateError('Напиток недоступен')),
          quantity: item.quantity,
          options: item.options,
        ),
    ];
  }

  @override
  Future<void> removeFromCart(DrinkEntity drink) async {
    final models = await localDataSource.getCartItems();

    // Удаляем все элементы с drinkName == drink.name
    models.removeWhere((m) => m.drinkName == drink.name);

    await localDataSource.saveCartItems(models);
  }

  @override
  Future<double> getTotalPrice() async {
    final items = await getCartItems();
    double sum = 0.0;
    for (final item in items) {
      sum += item.lineTotal;
    }
    return sum;
  }
}
