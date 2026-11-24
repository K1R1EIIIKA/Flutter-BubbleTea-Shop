import 'package:labs/features/shop/domain/entities/drink_entity.dart';

/// Модель напитка для работы с JSON
class DrinkModel {
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final String? displayName;
  final String? displayDescription;
  final DrinkCategory? category;
  final bool popular;

  DrinkModel({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    this.displayName,
    this.displayDescription,
    this.category,
    this.popular = false,
  });

  factory DrinkModel.fromJson(Map<String, dynamic> json) {
    return DrinkModel(
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
      price: (json['price'] as num).toDouble(),
      displayName: json['nameRu'] as String?,
      displayDescription: json['descriptionRu'] as String?,
      category: DrinkCategory.values
          .where((category) => category.name == json['category'])
          .firstOrNull,
      popular: json['popular'] == true,
    );
  }

  /// Преобразовать в доменную сущность
  DrinkEntity toEntity() {
    return DrinkEntity(
      name: name,
      description: description,
      imagePath: imagePath,
      price: price,
      displayName: displayName,
      displayDescription: displayDescription,
      category: category,
      popular: popular,
    );
  }
}
