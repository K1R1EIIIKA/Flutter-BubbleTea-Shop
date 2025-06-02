import '../cart/cart_page.dart';

class CartController {
  static final CartController _instance = CartController._internal();

  factory CartController() => _instance;

  CartController._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem(CartItem item) {
    _items.add(item);
  }

  void removeItem(CartItem item) {
    _items.remove(item);
  }

  void clear() {
    _items.clear();
  }

  double get total => _items.fold(0.0, (sum, item) => sum + item.price);
}