import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/drink_notes_repository.dart';

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
  DrinkNotesCubit(this.repository) : super(const DrinkNotesState());

  final DrinkNotesRepository repository;

  Future<void> load() async {
    emit(const DrinkNotesState());
    try {
      final notes = await repository.readNotes();
      if (!isClosed) emit(DrinkNotesState(notes: notes, ready: true));
    } catch (error, stackTrace) {
      if (!isClosed) {
        addError(error, stackTrace);
        emit(const DrinkNotesState(failed: true));
      }
    }
  }

  Future<void> setFavorite(String key, bool favorite) async =>
      _save(key, await repository.setFavorite(key, favorite));

  Future<void> pickPhoto(String key) async {
    final note = await repository.pickPhoto(key);
    if (note != null) _save(key, note);
  }

  Future<void> removePhoto(String key) async =>
      _save(key, await repository.removePhoto(key));

  Future<Uint8List> readPhoto(String name) => repository.readPhoto(name);

  void _save(String key, DrinkNote note) {
    if (!isClosed) {
      emit(DrinkNotesState(notes: {...state.notes, key: note}, ready: true));
    }
  }
}
