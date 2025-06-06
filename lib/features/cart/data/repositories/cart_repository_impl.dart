import 'dart:async';
import 'package:labs/features/shop/domain/entities/drink_entity.dart';
import 'package:labs/features/shop/domain/repositories/drink_repository.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

/// Реализация CartRepository, которая использует локальный DataSource
/// и DrinkRepository, чтобы собрать полные DrinkEntity по имени.
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final DrinkRepository drinkRepository;

  CartRepositoryImpl({
    required this.localDataSource,
    required this.drinkRepository,
  });

  @override
  Future<void> addToCart(DrinkEntity drink) async {
    // Сначала получаем текущий список моделей
    final models = await localDataSource.getCartItems();

    // Проверяем, есть ли уже элемент с этим drink.name
    final index = models.indexWhere((m) => m.drinkName == drink.name);
    if (index >= 0) {
      // Если есть, увеличиваем quantity
      final existing = models[index];
      models[index] = CartItemModel(
        drinkName: existing.drinkName,
        quantity: existing.quantity + 1,
      );
    } else {
      // Иначе добавляем новый
      models.add(CartItemModel(drinkName: drink.name, quantity: 1));
    }

    // Сохраняем обновлённый список обратно
    await localDataSource.saveCartItems(models);
  }

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final models = await localDataSource.getCartItems();
    final List<CartItemEntity> entities = [];

    // Для каждого CartItemModel нужно получить полный DrinkEntity по имени
    for (final model in models) {
      final drinkEntity = await drinkRepository.getDrinkByName(model.drinkName);
      entities.add(CartItemEntity(
        drink: drinkEntity,
        quantity: model.quantity,
      ));
    }
    return entities;
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
      sum += item.drink.price * item.quantity;
    }
    return sum;
  }
}
