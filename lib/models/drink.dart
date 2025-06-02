class Drink {
  final String name;
  final String description;
  final String imagePath;
  final double price;

  Drink({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      name: json['name'],
      description: json['description'],
      imagePath: json['imagePath'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
