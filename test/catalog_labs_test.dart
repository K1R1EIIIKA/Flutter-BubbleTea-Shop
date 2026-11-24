import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:labs/features/shop/drink.dart';
import 'package:labs/features/shop/drink_catalog.dart';
import 'package:labs/features/shop/drink_notes_store.dart';
import 'package:labs/features/shop/drink_notes_cubit.dart';
import 'package:labs/features/shop/shop_cubit.dart';

const _mango = <String, Object>{
  'name': 'Mango',
  'description': 'Mango tea',
  'imagePath': 'assets/img/tea/mango.png',
  'price': 350,
};

DrinkCatalog _catalog(Future<String?> Function() read) =>
    DrinkCatalog(readCachedCatalog: read);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Drink JSON mapping', () {
    test('Converts an integer price to double', () {
      expect(Drink.fromJson(_mango).price, isA<double>());
      expect(Drink.fromJson(_mango).price, 350.0);
    });

    test('Preserves fractional prices', () {
      expect(Drink.fromJson({..._mango, 'price': 349.50}).price, 349.50);
    });

    test(
      'Uses the original name and description when translation is absent',
      () {
        final drink = Drink.fromJson(_mango);
        expect(drink.displayName, 'Mango');
        expect(drink.displayDescription, 'Mango tea');
      },
    );

    test('Keeps the canonical key when displaying a translation', () {
      final drink = Drink.fromJson({
        ..._mango,
        'nameRu': 'Манго',
        'descriptionRu': 'Чай с манго',
      });
      expect(drink.name, 'Mango');
      expect(drink.displayName, 'Манго');
      expect(drink.displayDescription, 'Чай с манго');
    });

    test('Maps a known category', () {
      expect(
        Drink.fromJson({..._mango, 'category': 'fruit'}).category,
        DrinkCategory.fruit,
      );
    });

    test('Accepts a future category without misclassifying the drink', () {
      expect(
        Drink.fromJson({..._mango, 'category': 'seasonal'}).category,
        isNull,
      );
    });

    test('Only explicit true marks a drink popular', () {
      expect(Drink.fromJson(_mango).popular, isFalse);
      expect(Drink.fromJson({..._mango, 'popular': true}).popular, isTrue);
    });

    test('Rejects a malformed price type', () {
      expect(
        () => Drink.fromJson({..._mango, 'price': '350'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Drink catalog', () {
    test('Uses the Room snapshot when it exists', () async {
      final drinks = await _catalog(() async => jsonEncode([_mango])).load();
      expect(drinks.map((drink) => drink.name), ['Mango']);
    });

    test('Reads the bundled JSON on first run without a snapshot', () async {
      final drinks = await _catalog(() async => null).load();
      expect(drinks.map((drink) => drink.name), contains('Mango'));
    });

    test('Keeps a valid empty snapshot empty', () async {
      expect(await _catalog(() async => '[]').load(), isEmpty);
    });

    test('Reports malformed JSON', () async {
      await expectLater(
        _catalog(() async => '[').load(),
        throwsFormatException,
      );
    });

    test('Looks up a drink by its canonical name', () async {
      final catalog = _catalog(() async => jsonEncode([_mango]));
      expect((await catalog.getDrinkByName('Mango')).price, 350.0);
    });

    test('Fails lookup of a missing drink', () async {
      final catalog = _catalog(() async => '[]');
      await expectLater(catalog.getDrinkByName('Mango'), throwsStateError);
    });
  });

  group('Catalog state', () {
    late String json;
    late ShopCubit cubit;
    late StreamController<void> changes;
    late Future<void> Function() refresh;

    setUp(() {
      changes = StreamController<void>();
      json = jsonEncode([_mango]);
      refresh = () async {};
      cubit = ShopCubit(
        catalog: _catalog(() async => json),
        refreshCatalog: () => refresh(),
        catalogChanges: changes.stream,
      );
    });

    tearDown(() async {
      await cubit.close();
      await changes.close();
    });

    test('Emits loading followed by the parsed catalog', () async {
      final states = cubit.stream.take(2).toList();
      expect(await cubit.loadDrinks(), isTrue);
      expect(await states, [isA<ShopLoading>(), isA<ShopLoaded>()]);
      expect((cubit.state as ShopLoaded).drinks.single.name, 'Mango');
    });

    test('Represents empty data as a successful empty catalog', () async {
      json = '[]';
      expect(await cubit.loadDrinks(), isTrue);
      expect((cubit.state as ShopLoaded).drinks, isEmpty);
    });

    test(
      'Exposes the initial error and loads again after correction',
      () async {
        json = '[';
        expect(await cubit.loadDrinks(), isFalse);
        expect(cubit.state, isA<ShopError>());
        json = '[]';
        expect(await cubit.refreshDrinks(), isTrue);
        expect(cubit.state, isA<ShopLoaded>());
      },
    );

    test('Manual refresh reads the replacement snapshot', () async {
      await cubit.loadDrinks();
      refresh = () async {
        json = '[]';
      };
      expect(await cubit.refreshDrinks(), isTrue);
      expect((cubit.state as ShopLoaded).drinks, isEmpty);
    });

    test('A failed refresh keeps the previous visible catalog', () async {
      await cubit.loadDrinks();
      refresh = () async => throw StateError('Storage unavailable');
      expect(await cubit.refreshDrinks(), isFalse);
      expect((cubit.state as ShopLoaded).drinks.single.name, 'Mango');
    });

    test(
      'A Room invalidation refreshes the visible catalog in place',
      () async {
        await cubit.loadDrinks();
        json = '[]';
        final update = cubit.stream.first;
        changes.add(null);
        final state = await update;
        expect(state, isA<ShopLoaded>());
        expect((state as ShopLoaded).drinks, isEmpty);
      },
    );
  });

  group('Personal drink notes', () {
    late _NotesStore store;
    late DrinkNotesCubit cubit;

    setUp(() {
      store = _NotesStore();
      cubit = DrinkNotesCubit(store);
    });
    tearDown(() => cubit.close());

    test(
      'Defaults to no favorite and no photo for an unrecorded drink',
      () async {
        await cubit.load();
        expect(cubit.state.ready, isTrue);
        final note = cubit.state.forDrink('Mango');
        expect(note.favorite, isFalse);
        expect(note.photoName, isNull);
      },
    );

    test('Adds a favorite without changing a different drink', () async {
      await cubit.load();
      await cubit.setFavorite('Mango', true);
      expect(cubit.state.forDrink('Mango').favorite, isTrue);
      expect(cubit.state.forDrink('Caramel').favorite, isFalse);
    });

    test('Restores saved metadata with a new Cubit', () async {
      store.notes['Mango'] = const DrinkNote(
        favorite: true,
        photoName: 'mango.image',
      );
      await cubit.load();
      expect(cubit.state.forDrink('Mango').favorite, isTrue);
      expect(cubit.state.forDrink('Mango').photoName, 'mango.image');
    });

    test('Removing a favorite preserves the personal photo', () async {
      await cubit.load();
      await cubit.setFavorite('Mango', true);
      store.selectedPhoto = 'mango.image';
      await cubit.pickPhoto('Mango');
      await cubit.setFavorite('Mango', false);
      expect(cubit.state.forDrink('Mango').favorite, isFalse);
      expect(cubit.state.forDrink('Mango').photoName, 'mango.image');
    });

    test('Picker cancellation keeps the existing photo', () async {
      store.notes['Mango'] = const DrinkNote(photoName: 'previous.image');
      await cubit.load();
      await cubit.pickPhoto('Mango');
      expect(cubit.state.forDrink('Mango').photoName, 'previous.image');
    });

    test('Photo replacement and removal preserve the favorite', () async {
      store.notes['Mango'] = const DrinkNote(
        favorite: true,
        photoName: 'old.image',
      );
      store.selectedPhoto = 'replacement.image';
      await cubit.load();
      await cubit.pickPhoto('Mango');
      expect(cubit.state.forDrink('Mango').photoName, 'replacement.image');
      await cubit.removePhoto('Mango');
      expect(cubit.state.forDrink('Mango').photoName, isNull);
      expect(cubit.state.forDrink('Mango').favorite, isTrue);
    });
  });
}

class _NotesStore implements DrinkNotesStore {
  final notes = <String, DrinkNote>{};
  String? selectedPhoto;

  @override
  Future<Map<String, DrinkNote>> readNotes() async => Map.of(notes);

  @override
  Future<DrinkNote> setFavorite(String drinkKey, bool favorite) async =>
      notes[drinkKey] = DrinkNote(
        favorite: favorite,
        photoName: notes[drinkKey]?.photoName,
      );

  @override
  Future<DrinkNote?> pickPhoto(String drinkKey) async {
    final selected = selectedPhoto;
    if (selected == null) return null;
    return notes[drinkKey] = DrinkNote(
      favorite: notes[drinkKey]?.favorite ?? false,
      photoName: selected,
    );
  }

  @override
  Future<DrinkNote> removePhoto(String drinkKey) async =>
      notes[drinkKey] = DrinkNote(favorite: notes[drinkKey]?.favorite ?? false);

  @override
  Future<Uint8List> readPhoto(String name) => throw UnimplementedError();
}
