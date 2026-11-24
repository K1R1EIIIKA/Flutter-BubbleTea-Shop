import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/drink_model.dart';

/// Интерфейс источника данных о напитках
abstract class DrinkLocalDataSource {
  Future<List<DrinkModel>> loadDrinksFromJson();
}

/// Реализация, читающая локальный JSON-файл
class DrinkLocalDataSourceImpl implements DrinkLocalDataSource {
  final String assetPath;
  final Future<String?> Function()? readCachedCatalog;

  DrinkLocalDataSourceImpl({required this.assetPath, this.readCachedCatalog});

  @override
  Future<List<DrinkModel>> loadDrinksFromJson() async {
    final jsonString =
        await readCachedCatalog?.call() ??
        await rootBundle.loadString(assetPath);
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => DrinkModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
