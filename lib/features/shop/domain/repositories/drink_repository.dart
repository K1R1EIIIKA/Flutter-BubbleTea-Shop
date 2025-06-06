

import '../entities/drink_entity.dart';

/// Контракт для получения информации о напитках
abstract class DrinkRepository {
  /// Получить список всех напитков
  Future<List<DrinkEntity>> getAllDrinks();

  /// Получить один напиток по его имени (name)
  Future<DrinkEntity> getDrinkByName(String name);
}
