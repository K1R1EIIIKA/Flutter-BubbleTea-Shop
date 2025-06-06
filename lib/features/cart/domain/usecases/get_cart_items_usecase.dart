import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

/// Use-case: получить все элементы корзины
class GetCartItemsUseCase {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  Future<List<CartItemEntity>> execute() {
    return repository.getCartItems();
  }
}
