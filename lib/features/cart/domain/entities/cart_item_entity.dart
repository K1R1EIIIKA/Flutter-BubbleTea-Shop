import '../../../shop/domain/entities/drink_entity.dart';

/// Сущность элемента корзины: напиток + количество
class CartItemEntity {
  final DrinkEntity drink;
  final int quantity;

  CartItemEntity({required this.drink, required this.quantity});
}
