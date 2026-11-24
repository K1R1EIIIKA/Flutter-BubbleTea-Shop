import 'dart:typed_data';

class DrinkNote {
  const DrinkNote({this.favorite = false, this.photoName});

  final bool favorite;
  final String? photoName;
}

abstract interface class DrinkNotesRepository {
  Future<Map<String, DrinkNote>> readNotes();
  Future<DrinkNote> setFavorite(String drinkKey, bool favorite);
  Future<DrinkNote?> pickPhoto(String drinkKey);
  Future<DrinkNote> removePhoto(String drinkKey);
  Future<Uint8List> readPhoto(String name);
}
