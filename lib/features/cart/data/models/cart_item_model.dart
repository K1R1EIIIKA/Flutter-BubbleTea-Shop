import '../../../shop/domain/entities/drink_options.dart';

/// Модель элемента корзины для хранения в SharedPreferences (JSON)
class CartItemModel {
  final String drinkName; // в качестве ключа используем уникальное имя напитка
  final int quantity;
  final DrinkOptions options;

  CartItemModel({
    required this.drinkName,
    required this.quantity,
    this.options = const DrinkOptions(),
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      drinkName: json['drinkName'] as String,
      quantity: json['quantity'] as int,
      options: DrinkOptions(
        size: _option(DrinkSize.values, json['size']),
        ice: _option(DrinkIce.values, json['ice']),
        sweetness: _option(DrinkSweetness.values, json['sweetness']),
        topping: _option(DrinkTopping.values, json['topping']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drinkName': drinkName,
      'quantity': quantity,
      'size': options.size.name,
      'ice': options.ice.name,
      'sweetness': options.sweetness.name,
      'topping': options.topping.name,
    };
  }

  static T _option<T extends Enum>(List<T> values, Object? name) => values
      .firstWhere((option) => option.name == name, orElse: () => values.first);
}
