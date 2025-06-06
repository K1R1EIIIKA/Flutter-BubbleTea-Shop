
import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/shop/domain/entities/drink_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/get_cart_items_usecase.dart';
import '../../domain/usecases/get_total_price_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';

part 'cart_state.dart';

/// Cubit для управления состоянием корзины
class CartCubit extends Cubit<CartState> {
  final GetCartItemsUseCase getCartItemsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final GetTotalPriceUseCase getTotalPriceUseCase;

  CartCubit({
    required this.getCartItemsUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.getTotalPriceUseCase,
  }) : super(CartInitial());

  /// Загрузить содержание корзины и сумму
  Future<void> loadCart() async {
    emit(CartLoading());
    try {
      final items = await getCartItemsUseCase.execute();
      final total = await getTotalPriceUseCase.execute();
      emit(CartLoaded(items: items, totalPrice: total));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  /// Добавить DrinkEntity в корзину
  Future<void> addDrink(DrinkEntity drink) async {
    emit(CartLoading());
    try {
      await addToCartUseCase.execute(drink);
      final items = await getCartItemsUseCase.execute();
      final total = await getTotalPriceUseCase.execute();
      emit(CartLoaded(items: items, totalPrice: total));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }

  /// Удалить DrinkEntity из корзины
  Future<void> removeDrink(DrinkEntity drink) async {
    emit(CartLoading());
    try {
      await removeFromCartUseCase.execute(drink);
      final items = await getCartItemsUseCase.execute();
      final total = await getTotalPriceUseCase.execute();
      emit(CartLoaded(items: items, totalPrice: total));
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }
}
