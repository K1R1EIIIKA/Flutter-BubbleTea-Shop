import 'package:equatable/equatable.dart';
import 'package:labs/features/cart/domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double totalPrice;
  final String? saveError;

  const CartLoaded({
    required this.items,
    required this.totalPrice,
    this.saveError,
  });

  int get itemCount => items.fold(0, (count, item) => count + item.quantity);

  @override
  List<Object?> get props => [items, totalPrice, saveError];
}

class CartError extends CartState {
  final String message;
  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}
