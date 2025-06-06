import '../entities/drink_entity.dart';
import '../repositories/drink_repository.dart';

class GetDrinkByNameUseCase {
  final DrinkRepository repository;

  GetDrinkByNameUseCase(this.repository);

  Future<DrinkEntity> execute(String name) {
    return repository.getDrinkByName(name);
  }
}
