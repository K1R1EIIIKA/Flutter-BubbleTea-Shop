import '../../../shop/domain/entities/drink_entity.dart';
import '../repositories/cart_repository.dart';

/// Use-case: добавить напиток в корзину (или увеличить quantity, если уже есть)
class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<void> execute(DrinkEntity drink) {
    return repository.addToCart(drink);
  }
}
