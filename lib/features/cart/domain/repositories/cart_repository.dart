import 'package:labs/features/shop/domain/entities/drink_entity.dart';

import '../entities/cart_item_entity.dart';
import '../entities/demo_order.dart';

/// Интерфейс (контракт) для работы с корзиной
abstract class CartRepository {
  /// Получить все элементы корзины
  Future<List<CartItemEntity>> getCartItems();

  /// Сохранить корзину целиком, включая количество каждой позиции.
  Future<void> saveCartItems(List<CartItemEntity> items);

  Future<List<DemoOrder>> getOrders();

  Future<void> saveOrder(DemoOrder order);

  Future<List<CartItemEntity>> getReorderItems(DemoOrder order);

  /// Добавить напиток drink в корзину.
  /// Если этот drink уже есть, увеличивает quantity на 1.
  Future<void> addToCart(DrinkEntity drink);

  /// Удалить напиток drink из корзины (целиком, независимо от quantity)
  Future<void> removeFromCart(DrinkEntity drink);

  /// Получить итоговую сумму стоимости всех товаров в корзине
  Future<double> getTotalPrice();
}
