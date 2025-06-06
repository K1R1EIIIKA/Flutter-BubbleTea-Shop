import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import 'cart_local_data_source.dart';

/// Реализация CartLocalDataSource на основе SharedPreferences
class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const _cartKey = 'CART_ITEMS_JSON';

  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final jsonString = sharedPreferences.getString(_cartKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final List<Map<String, dynamic>> jsonList =
    items.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(_cartKey, jsonString);
  }
}
