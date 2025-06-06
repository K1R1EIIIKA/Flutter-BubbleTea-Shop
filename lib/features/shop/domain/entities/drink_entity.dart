/// Доменная сущность напитка
class DrinkEntity {
  final String name;
  final String description;
  final String imagePath;
  final double price;

  DrinkEntity({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
  });
}
