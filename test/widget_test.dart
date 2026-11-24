import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labs/core/main.dart';
import 'package:labs/features/auth/auth_store.dart';
import 'package:labs/features/cart/cart_store.dart';
import 'package:labs/features/shop/drink_catalog.dart';
import 'package:labs/features/cart/demo_order.dart';
import 'package:labs/features/shop/drink_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MyApp> _testApp() async {
  final preferences = await SharedPreferences.getInstance();
  final json = File('assets/data/drinks.json').readAsStringSync();
  final catalog = DrinkCatalog(readCachedCatalog: () async => json);
  return MyApp(
    catalog: catalog,
    cartStore: CartStore(preferences, catalog),
    authStore: AuthStore(preferences),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Existing local accounts can restore a session and sign in again',
    () async {
      const savedAccount = {
        'username': 'Гость',
        'email': 'test@example.com',
        'password': 'demo-password',
      };
      SharedPreferences.setMockInitialValues({
        'AUTH_USER_JSON': jsonEncode(savedAccount),
        'USERS_LIST_JSON': jsonEncode([savedAccount]),
      });
      final preferences = await SharedPreferences.getInstance();
      final store = AuthStore(preferences);

      expect((await store.currentUser())?.username, 'Гость');
      await store.logout();
      expect(await store.currentUser(), isNull);
      await expectLater(store.login('Гость', 'wrong'), throwsException);
      expect(
        (await store.login('Гость', 'demo-password')).email,
        'test@example.com',
      );
      await expectLater(
        store.register('Гость', 'other@example.com', 'pass'),
        throwsException,
      );
      await store.register('Новый', 'new@example.com', 'pass');
      expect((await AuthStore(preferences).currentUser())?.username, 'Новый');
      await store.logout();
      expect((await store.login('Новый', 'pass')).email, 'new@example.com');
    },
  );

  testWidgets('Amounts from legacy demo orders are read in rubles once', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'CART_ITEMS_JSON': jsonEncode({
        'items': [],
        'orders': [
          {
            'placedAt': '2026-11-24T00:00:00Z',
            'items': [
              {
                'drinkName': 'Mango',
                'displayName': 'Манго',
                'quantity': 2,
                'unitPrice': 6.99,
              },
            ],
          },
        ],
      }),
    });
    final app = await _testApp();
    final cartStore = app.cartStore;
    final legacy = (await cartStore.getOrders()).single;
    expect(legacy.total, 700);
    await cartStore.saveOrder(legacy);
    expect((await cartStore.getOrders()).map((order) => order.total), [
      700,
      700,
    ]);
  });

  testWidgets('A customized drink is saved and restored from order history', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'CART_ITEMS_JSON': '[{"drinkName":"Mango","quantity":1}]',
    });
    final app = await _testApp();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 600);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(find.text('Мои заказы'), findsNothing);
    await tap(find.byTooltip('Профиль'));
    await tap(find.text('Мои заказы'));
    expect(find.text('У вас пока нет заказов.'), findsOneWidget);
    await tap(find.byTooltip('Назад'));
    await tap(find.byTooltip('Назад'));
    expect(find.text('Добро пожаловать!'), findsOneWidget);
    final news = find.widgetWithText(FilledButton, 'Новости');
    final carousel = find.byType(PageView);
    final viewport = tester.getRect(carousel);
    final visibleCards =
        find
            .descendant(of: carousel, matching: find.byType(Material))
            .evaluate()
            .map((card) => tester.getRect(find.byWidget(card.widget)))
            .where(viewport.overlaps)
            .toList()
          ..sort((left, right) => left.left.compareTo(right.left));
    expect(visibleCards, hasLength(3));
    expect(visibleCards.first.left, lessThan(viewport.left));
    expect(visibleCards.last.right, greaterThan(viewport.right));
    expect(visibleCards[1].center.dx, closeTo(viewport.center.dx, 0.1));
    expect(
      tester.getBottomLeft(news).dy,
      lessThan(tester.getTopLeft(carousel).dy),
    );
    expect(tester.getSize(news).width, closeTo(visibleCards[1].width, 0.1));
    expect(tester.getCenter(news).dx, closeTo(viewport.center.dx, 0.1));
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    const newsChannel = MethodChannel('bubble_tea/news');
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(newsChannel, (_) async => false);
    addTearDown(() => messenger.setMockMethodCallHandler(newsChannel, null));
    await tap(news);
    expect(find.text('Что нового в Biba & Boba'), findsOneWidget);
    await tap(find.byTooltip('Назад'));

    final controller = tester.widget<PageView>(carousel).controller!;
    expect(controller.viewportFraction, lessThan(1));
    expect(controller.page!.round() % 3, 0);
    for (var swipe = 1; swipe <= 15; swipe++) {
      await tester.drag(carousel, const Offset(220, 0));
      await tester.pumpAndSettle();
      expect(controller.page!.round() % 3, -swipe % 3);
    }
    for (var swipe = 1; swipe <= 15; swipe++) {
      await tester.drag(carousel, const Offset(-220, 0));
      await tester.pumpAndSettle();
      expect(controller.page!.round() % 3, swipe % 3);
    }
    expect(find.textContaining(RegExp(r'^\d+\s*/\s*\d+$')), findsNothing);
    final tea = find.text('Чайные');
    await tester.scrollUntilVisible(
      tea.hitTestable(),
      110,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(tea);
    expect(find.byKey(const ValueKey('menu-Mango')), findsNothing);
    final all = find.text('Все');
    await tester.scrollUntilVisible(
      all.hitTestable(),
      -100,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(all);
    final mango = find.byKey(const ValueKey('menu-Mango'));
    await tester.scrollUntilVisible(
      mango.hitTestable(),
      110,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(mango);
    for (final label in ['700 мл', 'Без льда', '50% сахара', 'Тапиока']) {
      final choice = find.textContaining(label);
      await tester.scrollUntilVisible(choice.hitTestable(), 120);
      await tap(choice);
    }
    await tap(find.widgetWithText(FilledButton, 'В корзину'));
    await tap(find.byTooltip('Назад'));
    await tap(find.byType(NavigationDestination).last);

    final cartStore = app.cartStore;
    const customized = DrinkOptions(
      size: DrinkSize.large,
      ice: DrinkIce.none,
      sweetness: DrinkSweetness.half,
      topping: DrinkTopping.tapioca,
    );
    final cart = await cartStore.getCartItems();
    expect(cart.map((item) => item.options), [
      const DrinkOptions(),
      customized,
    ]);
    expect(cart.last.unitPrice, 475);
    final edit = find.byTooltip('Изменить напиток: Манго-танго');
    await tester.scrollUntilVisible(edit.hitTestable(), 100);
    await tap(edit);
    final changeDrink = find.text('Выбрать другой напиток');
    await tester.scrollUntilVisible(changeDrink.hitTestable(), 100);
    await tap(changeDrink);
    final drinkChoices = find.byType(BottomSheet);
    final current = find.descendant(
      of: drinkChoices,
      matching: find.text('Манго-танго'),
    );
    expect(
      tester
          .widget<ListTile>(
            find.ancestor(of: current, matching: find.byType(ListTile)),
          )
          .selected,
      isTrue,
    );
    final caramel = find.descendant(
      of: drinkChoices,
      matching: find.text('Карамельное облако'),
    );
    await tester.scrollUntilVisible(
      caramel.hitTestable(),
      90,
      scrollable: find.descendant(
        of: drinkChoices,
        matching: find.byType(Scrollable),
      ),
    );
    await tap(caramel);
    await tap(find.text('Сохранить изменения'));
    expect((await cartStore.getCartItems()).first.drink.name, 'Caramel');
    await tap(find.text('Оформить демозаказ'));
    for (final method in DemoPaymentMethod.values) {
      await tester.scrollUntilVisible(
        find.text(method.label).hitTestable(),
        100,
      );
    }
    final sbp = find.text('СБП');
    await tester.scrollUntilVisible(sbp.hitTestable(), -100);
    await tap(sbp);
    final confirm = find.text('Подтвердить демозаказ');
    await tester.scrollUntilVisible(confirm.hitTestable(), 140);
    await tap(confirm);
    expect(await cartStore.getCartItems(), isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tap(find.byTooltip('Профиль'));
    await tap(find.text('Мои заказы'));
    final order = (await cartStore.getOrders()).single;
    expect(order.total, 825);
    expect(order.paymentMethod, DemoPaymentMethod.sbp);
    await tap(find.textContaining('Демозаказ ·'));
    final repeat = find.text('Повторить заказ');
    await tester.scrollUntilVisible(repeat.hitTestable(), 140);
    await tap(repeat);
    final restored = await cartStore.getCartItems();
    expect(restored.map((item) => item.options), [
      const DrinkOptions(),
      customized,
    ]);
    expect(restored.map((item) => item.quantity), [1, 1]);
    expect(restored.first.drink.name, 'Caramel');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Guest order works on a compact screen and cart survives restart',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final app = await _testApp();

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 600);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Профиль'), findsOneWidget);
      expect(find.bySemanticsLabel('Профиль'), findsWidgets);

      const names = {
        'Strawberry & Cactus': 'Клубничный кактус',
        'Mango': 'Манго-танго',
        'Blue Matcha': 'Матча индиго',
        'Caramel': 'Карамельное облако',
        'In Bottle': 'Боба с собой',
        'Strawberry': 'Клубничный поп',
      };
      for (final entry in names.entries) {
        final card = find.byKey(ValueKey('menu-${entry.key}'));
        await tester.scrollUntilVisible(
          card.hitTestable(),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.bySemanticsLabel(RegExp('Подробнее: ${entry.value}')),
          findsWidgets,
        );
        await tester.tap(card);
        await tester.pumpAndSettle();

        final addButton = find.widgetWithText(FilledButton, 'В корзину');
        expect(addButton.hitTestable(), findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        expect(find.text('Добавлено в корзину'), findsOneWidget);

        await tester.tap(find.byTooltip('Назад'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).last);
      await tester.pumpAndSettle();

      final cartStore = app.cartStore;
      expect(await cartStore.getCartItems(), hasLength(6));
      expect(
        find.bySemanticsLabel('Увеличить количество: Клубничный кактус'),
        findsWidgets,
      );
      expect(
        find.byTooltip('Увеличить количество: Клубничный кактус'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byTooltip('Увеличить количество: Клубничный кактус').hitTestable(),
        120,
      );
      await tester.tap(
        find.byTooltip('Увеличить количество: Клубничный кактус'),
      );
      await tester.pumpAndSettle();
      expect((await cartStore.getCartItems()).first.quantity, 2);
      await tester.tap(
        find.byTooltip('Уменьшить количество: Клубничный кактус'),
      );
      await tester.pumpAndSettle();
      expect((await cartStore.getCartItems()).first.quantity, 1);

      final checkout = find.widgetWithText(FilledButton, 'Оформить демозаказ');
      expect(checkout.hitTestable(), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Клубничный поп'), 240);
      expect(checkout.hitTestable(), findsOneWidget);
      await tester.tap(checkout);
      await tester.pumpAndSettle();
      expect(
        find.text('Демонстрационный режим. Оплата не списывается.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Назад'));
      await tester.pumpAndSettle();
      expect(await cartStore.getCartItems(), hasLength(6));

      await tester.tap(checkout);
      await tester.pumpAndSettle();
      final confirm = find.widgetWithText(
        FilledButton,
        'Подтвердить демозаказ',
      );
      await tester.scrollUntilVisible(confirm.hitTestable(), 180);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Демозаказ оформлен'), -240);
      expect(find.text('Демозаказ оформлен'), findsOneWidget);
      expect(await cartStore.getCartItems(), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
