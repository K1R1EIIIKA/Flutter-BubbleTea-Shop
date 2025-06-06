import 'package:equatable/equatable.dart';
import 'package:labs/features/shop/domain/entities/drink_entity.dart';

class CartItemEntity extends Equatable {
  final DrinkEntity drink;
  final int quantity;

  const CartItemEntity({required this.drink, required this.quantity});

  CartItemEntity copyWith({DrinkEntity? drink, int? quantity}) {
    return CartItemEntity(
      drink: drink ?? this.drink,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [drink, quantity];
}
