import '../entities/drink_entity.dart';
import '../repositories/drink_repository.dart';

class GetAllDrinksUseCase {
  final DrinkRepository repository;

  GetAllDrinksUseCase(this.repository);

  Future<List<DrinkEntity>> execute() {
    return repository.getAllDrinks();
  }
}
