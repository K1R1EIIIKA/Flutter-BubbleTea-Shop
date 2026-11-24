import 'package:equatable/equatable.dart';
import 'package:labs/features/shop/drink.dart';
import '../shop/drink_options.dart';

class CartItem extends Equatable {
  final Drink drink;
  final int quantity;
  final DrinkOptions options;
  final double? recordedUnitPrice;

  const CartItem({
    required this.drink,
    required this.quantity,
    this.options = const DrinkOptions(),
    this.recordedUnitPrice,
  });

  double get unitPrice => recordedUnitPrice ?? drink.price + options.extra;
  double get lineTotal => unitPrice * quantity;

  bool sameVariant(CartItem other) =>
      drink.name == other.drink.name && options == other.options;

  CartItem copyWith({Drink? drink, int? quantity}) {
    return CartItem(
      drink: drink ?? this.drink,
      quantity: quantity ?? this.quantity,
      options: options,
      recordedUnitPrice: recordedUnitPrice,
    );
  }

  @override
  List<Object?> get props => [drink, quantity, options, recordedUnitPrice];
}
