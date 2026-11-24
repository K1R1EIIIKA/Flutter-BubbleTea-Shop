import 'cart_item.dart';

enum DemoPaymentMethod {
  card('Банковская карта'),
  sbp('СБП'),
  sberPay('SberPay'),
  yandexPay('Яндекс Пэй');

  const DemoPaymentMethod(this.label);
  final String label;
}

class DemoOrder {
  const DemoOrder({
    required this.placedAt,
    required this.items,
    this.paymentMethod,
  });

  final DateTime placedAt;
  final List<CartItem> items;
  final DemoPaymentMethod? paymentMethod;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);
}
