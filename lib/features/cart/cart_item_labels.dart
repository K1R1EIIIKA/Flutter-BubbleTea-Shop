import '../shop/drink_options.dart';
import 'cart_item.dart';

String cartItemOptions(CartItem item) {
  final options = item.options;
  return '${options.size.label} · ${options.ice.label} · ${options.sweetness.label} · ${options.topping.label}';
}

String cartItemActionLabel(CartItem item) =>
    item.options == const DrinkOptions()
    ? item.drink.displayName
    : '${item.drink.displayName}, ${cartItemOptions(item)}';
