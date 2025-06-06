part of 'shop_cubit.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<DrinkEntity> drinks;
  const ShopLoaded(this.drinks);

  @override
  List<Object?> get props => [drinks];
}

class ShopError extends ShopState {
  final String message;
  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}
