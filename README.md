# Bubble Tea App

Курсовой проект: **Исследование современных подходов и паттернов при разработке клиент-серверных мобильных приложений**

## Описание

Приложение «Bubble Tea» демонстрирует два архитектурных подхода: **Vanilla Flutter** и **Clean Architecture + Provider**. Основной функционал:

* Аутентификация (локально и через Google)
* Просмотр списка напитков (получение данных из mock API или Firebase)
* Страница деталей напитка
* Корзина покупок

## Требования

* Flutter SDK ≥ 3.7.0
* Android Studio или VS Code
* Java JDK (для Android): путь к `keytool` в PATH
* Для Android: minSdkVersion ≥ 23
* Firebase CLI (для локальной настройки API)

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
flutter run
```

## Google Sign-In

1. Добавьте SHA-1 отпечаток в Firebase Console (Project Settings → General → SHA certificate fingerprints)
2. Перескачайте `google-services.json` и замените в `android/app`
3. Выполните:

```
flutter clean
flutter pub get
flutter run
```

## API

В проекте с "грязной" архитектурой используется внешнее API.
В проекте с "чистойз архитектурой данные загружаются из локального JSON.

## Локальное сохранение данных

Используется `shared_preferences` для хранения:

* Список зарегистрированных пользователей
* Статус входа (`is_logged_in`)
* Текущий username

## Структура проекта

Подробнее см. `lib/`:

* `main.dart` — точка входа
* `features/` — функциональные модули (shop, auth)
* `core/` — общие утилиты и абстракции
* `app/` — темы, роутинг и конфигурация
