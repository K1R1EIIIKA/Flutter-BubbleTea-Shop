/// Модель элемента корзины для хранения в SharedPreferences (JSON)
class CartItemModel {
  final String drinkName;  // в качестве ключа используем уникальное имя напитка
  final int quantity;

  CartItemModel({
    required this.drinkName,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      drinkName: json['drinkName'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drinkName': drinkName,
      'quantity': quantity,
    };
  }
}
