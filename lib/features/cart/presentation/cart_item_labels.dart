import '../../shop/domain/entities/drink_options.dart';
import '../domain/entities/cart_item_entity.dart';

String cartItemOptions(CartItemEntity item) {
  final options = item.options;
  return '${options.size.label} · ${options.ice.label} · ${options.sweetness.label} · ${options.topping.label}';
}

String cartItemActionLabel(CartItemEntity item) =>
    item.options == const DrinkOptions()
    ? item.drink.displayName
    : '${item.drink.displayName}, ${cartItemOptions(item)}';
