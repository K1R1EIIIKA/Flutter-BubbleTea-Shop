import 'package:labs/features/shop/domain/entities/drink_entity.dart';

import '../entities/cart_item_entity.dart';

/// Интерфейс (контракт) для работы с корзиной
abstract class CartRepository {
  /// Получить все элементы корзины
  Future<List<CartItemEntity>> getCartItems();

  /// Добавить напиток drink в корзину.
  /// Если этот drink уже есть, увеличивает quantity на 1.
  Future<void> addToCart(DrinkEntity drink);

  /// Удалить напиток drink из корзины (целиком, независимо от quantity)
  Future<void> removeFromCart(DrinkEntity drink);

  /// Получить итоговую сумму стоимости всех товаров в корзине
  Future<double> getTotalPrice();
}
