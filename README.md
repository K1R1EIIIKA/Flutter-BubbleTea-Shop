# Bubble Tea App

Курсовой проект: **Исследование современных подходов и паттернов при разработке клиент-серверных мобильных приложений**

## Описание

Код Flutter-магазина «Bubble Tea» сгруппирован по функциям. В каждой папке экраны показывают данные, Cubit обрабатывают действия пользователя и обновляют состояние, а классы хранилищ читают и записывают данные.

* Аутентификация (локально и через Google)
* Просмотр каталога напитков из локального JSON
* Страница деталей напитка
* Корзина покупок

## Требования

* Flutter SDK ≥ 3.7.0
* Android Studio или VS Code
* Java JDK (для Android): путь к `keytool` в PATH
* Для Android: minSdkVersion ≥ 23

## Установка и запуск

Клонируйте репозиторий:

```
git clone https://github.com/yourusername/bubble-tea-app.git
cd bubble-tea-app
```

Установите зависимости Flutter:

```
flutter pub get
```

Настройте Firebase:

* Убедитесь, что файл `android/app/google-services.json` находится в проекте
* Убедитесь, что `ios/Runner/GoogleService-Info.plist` добавлен (для iOS)

Запустите эмулятор Android или подключите устройство

Запустите приложение:

```
flutter run -t lib/core/main.dart
```

## Google Sign-In

1. Добавьте SHA-1 отпечаток в Firebase Console (Project Settings → General → SHA certificate fingerprints)
2. Перескачайте `google-services.json` и замените в `android/app`
3. Выполните:

```
flutter clean
flutter pub get
flutter run -t lib/core/main.dart
```

## Локальное сохранение данных

- `SharedPreferences` хранит локальные учётные записи, текущий сеанс, корзину и историю демозаказов.
- `assets/data/drinks.json` содержит каталог. На Android Room хранит его кэш, избранное и пути личных фото. WorkManager обновляет кэш.

## Структура проекта

- `lib/core/main.dart` создаёт хранилища и Cubit, задаёт маршруты и запускает приложение.
- `lib/features/shop/` содержит каталог, карточку напитка и новости. `DrinkCatalog` читает данные, `ShopCubit` хранит состояние списка.
- `lib/features/cart/` содержит корзину, оформление и историю заказов. `CartCubit` меняет состав корзины, `CartStore` сохраняет его.
- `lib/features/auth/` содержит вход, регистрацию и профиль. `AuthCubit` управляет состоянием входа, `AuthStore` работает с учётными записями и сеансом.
- `android/app/` содержит нативную часть Android, в том числе Room и WorkManager.

Например, при добавлении напитка экран вызывает `CartCubit.addDrink()`. Cubit меняет корзину и сохраняет её через `CartStore`. После успешного сохранения экран получает новое состояние и показывает обновлённую корзину.
