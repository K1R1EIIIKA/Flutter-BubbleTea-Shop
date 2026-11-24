# Bubble Tea Shop

## Какой проект запускать

- Магазин написан на Flutter. Открывайте каталог с `pubspec.yaml` и запускайте `lib/core/main.dart`.
- `composeApp/` и `iosApp/` относятся к шаблону Kotlin Compose Multiplatform. APK из `composeApp/build/` собирает шаблонный модуль `org.example.project`. Android-модуль Flutter находится в `android/`.

## Команды

Выполняйте из корня проекта:

```sh
flutter pub get
flutter devices
flutter run -d <device-id> -t lib/core/main.dart
flutter run -d chrome -t lib/core/main.dart
flutter analyze
flutter test
```

Для APK самого магазина используйте `flutter build apk --debug -t lib/core/main.dart`. Web-запуск подходит для быстрой проверки интерфейса. Для отчёта о мобильном тестировании указывайте фактические устройства, версии ОС и результаты прогона.

## Где менять код

- `lib/core/main.dart` создаёт хранилища и Cubit, настраивает маршруты и навигацию между каталогом и корзиной.
- `lib/features/auth`, `lib/features/shop` и `lib/features/cart` группируют код по функциям. В папках `screens/` находятся экраны, Cubit управляют состоянием, а классы `AuthStore`, `DrinkCatalog` и `CartStore` работают с данными.
- Каталог загружается из `assets/data/drinks.json`. Если меняете пути к изображениям, сверяйте их с файлами под `assets/img/` и объявлениями в `pubspec.yaml`.
- `ShopPage` открывает `DrinkDetailPage` из `lib/features/shop/screens/drink_detail_page.dart`.

## Лабораторные работы

- №1–2: настройка Android Studio и каталог на Kotlin и Compose. Модуль `composeApp/` содержит стартовый шаблон.
- №3–9 выполняются в Android-сборке Flutter-магазина. Метки Logcat: `BubbleTeaLifecycle`, `BubbleTeaScreen` в `flutter` и `BubbleTeaCatalog`.
- Android читает каталог из кэша Room с резервным чтением того же `assets/data/drinks.json`. WorkManager обновляет кэш из JSON, избранное и пути личных фото Room хранит отдельно. APK для проверки этих функций собирайте из Flutter-проекта.
- Откройте «Новости» через кнопку над популярными напитками. Совместимый Android WebView отображает локальные статьи. При недоступном провайдере статьи показывает Flutter. Сценарии автоматизированных проверок находятся в `test/catalog_labs_test.dart` и `test/widget_test.dart`.
- Меню и корзина доступны без входа. Корзина хранится локально, а оформление демонстрирует проверку состава и подтверждение заказа без оплаты. Сценарий проверяется в `test/widget_test.dart`.
- Маршрут восстановления пароля отсутствует. Для проверки Google Sign-In нужен вход через Google на целевой платформе с настроенными учётными данными приложения.

## Изменения в Git

- Перед коммитом проверьте `git status --short` и `git diff --cached`. Стадируйте нужные файлы явно. Gradle-кэш, файлы из `composeApp/build/` и машинные настройки `local.properties` уже отслеживаются и могут меняться при запуске IDE или сборки.
- Храните ключи подписи и пароли вне репозитория. Текущая Android-конфигурация Flutter использует debug-подпись для release-сборки.
