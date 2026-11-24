import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'drink_notes_store.dart';

class DrinkNotesState {
  const DrinkNotesState({
    this.notes = const {},
    this.ready = false,
    this.failed = false,
  });

  final Map<String, DrinkNote> notes;
  final bool ready;
  final bool failed;

  DrinkNote forDrink(String key) => notes[key] ?? const DrinkNote();
}

class DrinkNotesCubit extends Cubit<DrinkNotesState> {
  DrinkNotesCubit(this._store) : super(const DrinkNotesState());

  final DrinkNotesStore _store;

  Future<void> load() async {
    emit(const DrinkNotesState());
    try {
      final notes = await _store.readNotes();
      if (!isClosed) emit(DrinkNotesState(notes: notes, ready: true));
    } catch (error, stackTrace) {
      if (!isClosed) {
        addError(error, stackTrace);
        emit(const DrinkNotesState(failed: true));
      }
    }
  }

  Future<void> setFavorite(String key, bool favorite) async =>
      _save(key, await _store.setFavorite(key, favorite));

  Future<void> pickPhoto(String key) async {
    final note = await _store.pickPhoto(key);
    if (note != null) _save(key, note);
  }

  Future<void> removePhoto(String key) async =>
      _save(key, await _store.removePhoto(key));

  Future<Uint8List> readPhoto(String name) => _store.readPhoto(name);

  void _save(String key, DrinkNote note) {
    if (!isClosed) {
      emit(DrinkNotesState(notes: {...state.notes, key: note}, ready: true));
    }
  }
}
