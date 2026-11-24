import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import 'cart_local_data_source.dart';

/// Реализация CartLocalDataSource на основе SharedPreferences
class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const _cartKey = 'CART_ITEMS_JSON';

  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final items = _read()['items'] as List;
    return items
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) => _write({
    ..._read(),
    'items': items.map((item) => item.toJson()).toList(),
  });

  @override
  List<Map<String, dynamic>> getOrders() =>
      (_read()['orders'] as List).cast<Map<String, dynamic>>();

  @override
  Future<void> saveOrder(Map<String, dynamic> order) => _write({
    'items': [],
    'orders': [order, ...getOrders()],
  });

  Map<String, dynamic> _read() {
    final raw = sharedPreferences.getString(_cartKey);
    final data = raw == null ? [] : jsonDecode(raw);
    if (data is List) return {'items': data, 'orders': []};
    return data as Map<String, dynamic>;
  }

  Future<void> _write(Map<String, dynamic> data) async {
    try {
      if (await sharedPreferences.setString(_cartKey, jsonEncode(data))) return;
    } catch (_) {
      await sharedPreferences.reload();
      rethrow;
    }
    await sharedPreferences.reload();
    throw StateError('Не удалось сохранить корзину');
  }
}
