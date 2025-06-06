import '../repositories/cart_repository.dart';

/// Use-case: получить итоговую сумму в корзине
class GetTotalPriceUseCase {
  final CartRepository repository;

  GetTotalPriceUseCase(this.repository);

  Future<double> execute() {
    return repository.getTotalPrice();
  }
}
