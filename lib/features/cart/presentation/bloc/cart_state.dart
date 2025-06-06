part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

/// Начальное состояние (корзина ещё не загружалась)
class CartInitial extends CartState {}

/// Идёт загрузка данных
class CartLoading extends CartState {}

/// Данные успешно загружены: передаём список элементов и итоговую сумму
class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double totalPrice;

  const CartLoaded({
    required this.items,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [items, totalPrice];
}

/// Состояние ошибки (покажем сообщение об ошибке)
class CartError extends CartState {
  final String message;

  const CartError({ required this.message });

  @override
  List<Object?> get props => [message];
}
