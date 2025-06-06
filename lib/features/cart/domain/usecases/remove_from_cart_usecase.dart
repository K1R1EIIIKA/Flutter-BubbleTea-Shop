import '../../../shop/domain/entities/drink_entity.dart';
import '../repositories/cart_repository.dart';

/// Use-case: удалить напиток из корзины целиком
class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<void> execute(DrinkEntity drink) {
    return repository.removeFromCart(drink);
  }
}
