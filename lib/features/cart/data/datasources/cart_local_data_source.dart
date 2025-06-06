import '../models/cart_item_model.dart';

/// Интерфейс локального DataSource для корзины
abstract class CartLocalDataSource {
  /// Загружает список CartItemModel из локального хранилища (SharedPreferences)
  Future<List<CartItemModel>> getCartItems();

  /// Сохраняет список CartItemModel в локальном хранилище
  Future<void> saveCartItems(List<CartItemModel> items);
}
