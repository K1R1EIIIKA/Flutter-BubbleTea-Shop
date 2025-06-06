import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labs/features/cart/domain/entities/cart_item_entity.dart';
import 'package:labs/features/cart/presentation/bloc/cart_state.dart';
import 'package:labs/features/shop/domain/entities/drink_entity.dart';


class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartLoaded(items: const [], totalPrice: 0));

  void addDrink(DrinkEntity drink) {
    if (state is CartLoaded) {
      final loaded = state as CartLoaded;
      final items = List<CartItemEntity>.from(loaded.items);
      final idx = items.indexWhere((item) => item.drink == drink);
      if (idx != -1) {
        // increment quantity
        items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
      } else {
        items.add(CartItemEntity(drink: drink, quantity: 1));
      }
      emit(CartLoaded(
        items: items,
        totalPrice: _calculateTotal(items),
      ));
    }
  }

  void removeDrink(DrinkEntity drink) {
    if (state is CartLoaded) {
      final loaded = state as CartLoaded;
      final items = List<CartItemEntity>.from(loaded.items);
      final idx = items.indexWhere((item) => item.drink == drink);
      if (idx != -1) {
        final item = items[idx];
        if (item.quantity > 1) {
          items[idx] = item.copyWith(quantity: item.quantity - 1);
        } else {
          items.removeAt(idx);
        }
      }
      emit(CartLoaded(
        items: items,
        totalPrice: _calculateTotal(items),
      ));
    }
  }

  double _calculateTotal(List<CartItemEntity> items) {
    return items.fold(0, (sum, item) => sum + item.drink.price * item.quantity);
  }
}
