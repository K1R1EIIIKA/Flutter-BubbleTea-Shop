enum DrinkCategory {
  fruit('Фруктовые'),
  tea('Чайные'),
  bottled('В бутылке');

  const DrinkCategory(this.label);
  final String label;
}

class Drink {
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final String displayName;
  final String displayDescription;
  final DrinkCategory? category;
  final bool popular;

  Drink({
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

  factory Drink.fromJson(Map<String, dynamic> json) => Drink(
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
