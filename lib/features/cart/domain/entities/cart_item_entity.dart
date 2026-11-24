import 'package:equatable/equatable.dart';
import 'package:labs/features/shop/domain/entities/drink_entity.dart';
import '../../../shop/domain/entities/drink_options.dart';

class CartItemEntity extends Equatable {
  final DrinkEntity drink;
  final int quantity;
  final DrinkOptions options;
  final double? recordedUnitPrice;

  const CartItemEntity({
    required this.drink,
    required this.quantity,
    this.options = const DrinkOptions(),
    this.recordedUnitPrice,
  });

  double get unitPrice => recordedUnitPrice ?? drink.price + options.extra;
  double get lineTotal => unitPrice * quantity;

  bool sameVariant(CartItemEntity other) =>
      drink.name == other.drink.name && options == other.options;

  CartItemEntity copyWith({DrinkEntity? drink, int? quantity}) {
    return CartItemEntity(
      drink: drink ?? this.drink,
      quantity: quantity ?? this.quantity,
      options: options,
      recordedUnitPrice: recordedUnitPrice,
    );
  }

  @override
  List<Object?> get props => [drink, quantity, options, recordedUnitPrice];
}
