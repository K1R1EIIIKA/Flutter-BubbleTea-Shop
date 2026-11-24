import 'package:flutter/services.dart';

import '../../domain/repositories/drink_notes_repository.dart';

class AndroidCatalog implements DrinkNotesRepository {
  static const _methods = MethodChannel('bubble_tea/catalog');
  static const _updates = EventChannel('bubble_tea/catalog_updates');

  Future<String?> readCatalog() => _methods.invokeMethod<String>('readCatalog');

  Future<void> refreshCatalog() =>
      _methods.invokeMethod<void>('refreshCatalog');

  Stream<void> get catalogChanges =>
      _updates.receiveBroadcastStream().map<void>((_) {});

  DrinkNote _note(Map<Object?, Object?> fields) => DrinkNote(
    favorite: fields['favorite'] as bool,
    photoName: fields['photoName'] as String?,
  );

  @override
  Future<Map<String, DrinkNote>> readNotes() async {
    final fields = await _methods.invokeMapMethod<String, Object?>('readNotes');
    return {
      for (final entry in fields!.entries)
        entry.key: _note(entry.value as Map<Object?, Object?>),
    };
  }

  @override
  Future<DrinkNote> setFavorite(String drinkKey, bool favorite) async {
    final fields = await _methods.invokeMapMethod<Object?, Object?>(
      'setFavorite',
      {'drinkKey': drinkKey, 'favorite': favorite},
    );
    return _note(fields!);
  }

  @override
  Future<DrinkNote?> pickPhoto(String drinkKey) async {
    final fields = await _methods.invokeMapMethod<Object?, Object?>(
      'pickPhoto',
      {'drinkKey': drinkKey},
    );
    return fields == null ? null : _note(fields);
  }

  @override
  Future<DrinkNote> removePhoto(String drinkKey) async {
    final fields = await _methods.invokeMapMethod<Object?, Object?>(
      'removePhoto',
      {'drinkKey': drinkKey},
    );
    return _note(fields!);
  }

  @override
  Future<Uint8List> readPhoto(String name) async =>
      (await _methods.invokeMethod<Uint8List>('readPhoto', name))!;
}
