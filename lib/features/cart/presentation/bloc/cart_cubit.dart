import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shop/domain/entities/drink_entity.dart';
import '../../../shop/domain/entities/drink_options.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/demo_order.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({required CartRepository repository})
    : _repository = repository,
      super(CartInitial());

  final CartRepository _repository;
  Future<void> _pending = Future.value();

  Future<void> load() => _enqueue(() async {
    if (state is CartLoaded || isClosed) return;
    emit(CartLoading());
    try {
      final items = await _repository.getCartItems();
      if (!isClosed) emit(_loaded(items));
    } catch (_) {
      if (!isClosed) {
        emit(const CartError(message: 'Не удалось загрузить корзину.'));
      }
    }
  });

  Future<bool> addDrink(
    DrinkEntity drink, {
    DrinkOptions options = const DrinkOptions(),
  }) => _changeQuantity(
    CartItemEntity(drink: drink, quantity: 1, options: options),
  );

  Future<bool> removeDrink(
    DrinkEntity drink, {
    DrinkOptions options = const DrinkOptions(),
  }) => _changeQuantity(
    CartItemEntity(drink: drink, quantity: -1, options: options),
  );

  Future<bool> _changeQuantity(CartItemEntity change) => _enqueue(() async {
    final current = state;
    if (current is! CartLoaded || isClosed) return false;

    final items = current.items.toList();
    _merge(items, change);
    return _save(items, current);
  });

  void _merge(List<CartItemEntity> items, CartItemEntity change) {
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

  Future<List<DemoOrder>> getOrders() => _enqueue(_repository.getOrders);

  Future<bool> updateDrink(
    CartItemEntity original,
    DrinkEntity drink,
    DrinkOptions options,
  ) => _enqueue(() async {
    final current = state;
    if (current is! CartLoaded || isClosed) return false;
    final items = current.items.toList();
    final index = items.indexWhere(original.sameVariant);
    if (index < 0) return false;
    final replacement = CartItemEntity(
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
      for (final item in await _repository.getReorderItems(order)) {
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
    return _save([], current, persist: () => _repository.saveOrder(order));
  });

  Future<bool> _save(
    List<CartItemEntity> items,
    CartLoaded previous, {
    Future<void> Function()? persist,
  }) async {
    try {
      await (persist?.call() ?? _repository.saveCartItems(items));
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

  CartLoaded _loaded(List<CartItemEntity> items) => CartLoaded(
    items: List.unmodifiable(items),
    totalPrice: items.fold(0, (sum, item) => sum + item.lineTotal),
  );

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final next = _pending.then((_) => action());
    _pending = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }
}
