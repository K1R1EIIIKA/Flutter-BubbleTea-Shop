import 'package:labs/features/shop/domain/entities/drink_entity.dart';

/// Модель напитка для работы с JSON
class DrinkModel {
  final String name;
  final String description;
  final String imagePath;
  final double price;

  DrinkModel({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
  });

  factory DrinkModel.fromJson(Map<String, dynamic> json) {
    return DrinkModel(
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Преобразовать в доменную сущность
  DrinkEntity toEntity() {
    return DrinkEntity(
      name: name,
      description: description,
      imagePath: imagePath,
      price: price,
    );
  }
}
