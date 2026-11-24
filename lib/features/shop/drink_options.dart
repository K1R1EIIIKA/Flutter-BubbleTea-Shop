import 'package:equatable/equatable.dart';

enum DrinkSize {
  standard('500 мл', 0),
  large('700 мл', 75);

  const DrinkSize(this.label, this.extra);
  final String label;
  final double extra;
}

enum DrinkIce {
  regular('Обычный лёд'),
  light('Меньше льда'),
  none('Без льда');

  const DrinkIce(this.label);
  final String label;
}

enum DrinkSweetness {
  regular('100% сахара'),
  half('50% сахара'),
  none('Без сахара');

  const DrinkSweetness(this.label);
  final String label;
}

enum DrinkTopping {
  none('Без добавки', 0),
  tapioca('Тапиока', 50),
  poppingBoba('Фруктовые шарики', 50);

  const DrinkTopping(this.label, this.extra);
  final String label;
  final double extra;
}

class DrinkOptions extends Equatable {
  const DrinkOptions({
    this.size = DrinkSize.standard,
    this.ice = DrinkIce.regular,
    this.sweetness = DrinkSweetness.regular,
    this.topping = DrinkTopping.none,
  });

  final DrinkSize size;
  final DrinkIce ice;
  final DrinkSweetness sweetness;
  final DrinkTopping topping;

  double get extra => size.extra + topping.extra;

  @override
  List<Object> get props => [size, ice, sweetness, topping];
}
