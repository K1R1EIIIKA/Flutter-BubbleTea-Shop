
import 'package:labs/features/shop/domain/entities/drink_entity.dart';
import 'package:labs/features/shop/domain/repositories/drink_repository.dart';

import '../datasources/drink_local_data_source.dart';

/// Реализация DrinkRepository, которая подгружает все напитки из JSON
class DrinkRepositoryImpl implements DrinkRepository {
  final DrinkLocalDataSource localDataSource;

  DrinkRepositoryImpl({ required this.localDataSource });

  @override
  Future<List<DrinkEntity>> getAllDrinks() async {
    final models = await localDataSource.loadDrinksFromJson();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<DrinkEntity> getDrinkByName(String name) async {
    final models = await localDataSource.loadDrinksFromJson();
    final model = models.firstWhere((m) => m.name == name);
    return model.toEntity();
  }
}
