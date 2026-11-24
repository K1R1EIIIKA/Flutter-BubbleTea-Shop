import 'package:flutter/material.dart';

const shopBackground = Color(0xFFFFFDFC);
const shopSurface = Color(0xFFF7F2EF);
const shopInk = Color(0xFF543A29);
const shopMuted = Color(0xFF665749);
const shopDivider = Color(0xFFE1D8D1);

final shopTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: shopInk).copyWith(
    primary: shopInk,
    onPrimary: Colors.white,
    surface: shopBackground,
    onSurface: shopInk,
    onSurfaceVariant: shopMuted,
  ),
  scaffoldBackgroundColor: shopBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: shopBackground,
    foregroundColor: shopInk,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(minimumSize: const Size(48, 52)),
  ),
  dividerColor: shopDivider,
);

String formatShopPrice(double price) {
  final digits = price.toStringAsFixed(2);
  final amount = digits.endsWith('.00')
      ? digits.substring(0, digits.length - 3)
      : digits.replaceAll('.', ',');
  return '$amount\u00a0₽';
}
