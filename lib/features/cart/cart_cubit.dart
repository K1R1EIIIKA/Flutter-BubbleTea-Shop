import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shop/drink.dart';
import '../shop/drink_options.dart';
import 'cart_item.dart';
import 'demo_order.dart';
import 'cart_store.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._store) : super(CartInitial());

  final CartStore _store;
  Future<void> _pending = Future.value();

  Future<void> load() => _enqueue(() async {
    if (state is CartLoaded || isClosed) return;
    emit(CartLoading());
    try {
      final items = await _store.getCartItems();
      if (!isClosed) emit(_loaded(items));
    } catch (_) {
      if (!isClosed) {
        emit(const CartError(message: 'Не удалось загрузить корзину.'));
      }
    }
  });

  Future<bool> addDrink(
    Drink drink, {
    DrinkOptions options = const DrinkOptions(),
  }) => _changeQuantity(CartItem(drink: drink, quantity: 1, options: options));

  Future<bool> removeDrink(
    Drink drink, {
    DrinkOptions options = const DrinkOptions(),
  }) => _changeQuantity(CartItem(drink: drink, quantity: -1, options: options));

  Future<bool> _changeQuantity(CartItem change) => _enqueue(() async {
    final current = state;
    if (current is! CartLoaded || isClosed) return false;

    final items = current.items.toList();
    _merge(items, change);
    return _save(items, current);
  });

  void _merge(List<CartItem> items, CartItem change) {
    final index = items.indexWhere(change.sameVariant);
    if (index == -1) {
      if (change.quantity > 0) items.add(change);
      return;
    }
    final item = items[index];
    final quantity = item.quantity + change.quantity;
    if (quantity == 0) {
      items.removeAt(index);
    } else {
      items[index] = item.copyWith(quantity: quantity);
    }
  }

  Future<List<DemoOrder>> getOrders() => _enqueue(_store.getOrders);

  Future<bool> updateDrink(
    CartItem original,
    Drink drink,
    DrinkOptions options,
  ) => _enqueue(() async {
    final current = state;
    if (current is! CartLoaded || isClosed) return false;
    final items = current.items.toList();
    final index = items.indexWhere(original.sameVariant);
    if (index < 0) return false;
    final replacement = CartItem(
      drink: drink,
      quantity: items[index].quantity,
      options: options,
    );
    if (replacement.sameVariant(items[index])) return true;
    items.removeAt(index);
    final matchingIndex = items.indexWhere(replacement.sameVariant);
    if (matchingIndex < 0) {
      items.insert(index, replacement);
    } else {
      _merge(items, replacement);
    }
    return _save(items, current);
  });

  Future<bool> repeatOrder(DemoOrder order) => _enqueue(() async {
    final current = state;
    if (current is! CartLoaded || isClosed) return false;
    try {
      final items = current.items.toList();
      for (final item in await _store.getReorderItems(order)) {
        _merge(items, item);
      }
      return _save(items, current);
    } catch (_) {
      return false;
    }
  });

  Future<bool> placeDemoOrder(
    CartLoaded reviewedCart, {
    required DemoPaymentMethod paymentMethod,
  }) => _enqueue(() async {
    final current = state;
    if (current is! CartLoaded || current.items.isEmpty || isClosed) {
      return false;
    }
    if (!listEquals(current.items, reviewedCart.items)) return false;
    final order = DemoOrder(
      placedAt: DateTime.now(),
      items: current.items,
      paymentMethod: paymentMethod,
    );
    return _save([], current, persist: () => _store.saveOrder(order));
  });

  Future<bool> _save(
    List<CartItem> items,
    CartLoaded previous, {
    Future<void> Function()? persist,
  }) async {
    try {
      await (persist?.call() ?? _store.saveCartItems(items));
      if (!isClosed) emit(_loaded(items));
      return true;
    } catch (_) {
      if (!isClosed) {
        emit(
          CartLoaded(
            items: previous.items,
            totalPrice: previous.totalPrice,
            saveError: 'Не удалось сохранить корзину. Повторите действие.',
          ),
        );
      }
      return false;
    }
  }

  CartLoaded _loaded(List<CartItem> items) => CartLoaded(
    items: List.unmodifiable(items),
    totalPrice: items.fold(0, (sum, item) => sum + item.lineTotal),
  );

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final next = _pending.then((_) => action());
    _pending = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }
}

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
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
