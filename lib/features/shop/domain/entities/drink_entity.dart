enum DrinkCategory {
  fruit('Фруктовые'),
  tea('Чайные'),
  bottled('В бутылке');

  const DrinkCategory(this.label);
  final String label;
}

/// Доменная сущность напитка
class DrinkEntity {
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final String displayName;
  final String displayDescription;
  final DrinkCategory? category;
  final bool popular;

  DrinkEntity({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    String? displayName,
    String? displayDescription,
    this.category,
    this.popular = false,
  }) : displayName = displayName ?? name,
       displayDescription = displayDescription ?? description;
}
