import 'dart:convert';

import 'package:flutter/services.dart';

import 'drink.dart';

class DrinkCatalog {
  const DrinkCatalog({this.readCachedCatalog});

  final Future<String?> Function()? readCachedCatalog;

  Future<List<Drink>> load() async {
    final json =
        await readCachedCatalog?.call() ??
        await rootBundle.loadString('assets/data/drinks.json');
    return (jsonDecode(json) as List)
        .cast<Map<String, dynamic>>()
        .map(Drink.fromJson)
        .toList();
  }

  Future<Drink> getDrinkByName(String name) async =>
      (await load()).firstWhere((drink) => drink.name == name);
}
