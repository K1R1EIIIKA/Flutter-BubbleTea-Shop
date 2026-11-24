# Лабораторная работа №1. Настройка среды разработки Android

Для работы использован Kotlin-модуль `composeApp` с Compose Multiplatform. Android-версия запускает общий интерфейс Compose из `MainActivity`. Идентификатор приложения — `org.example.project`.

## 3. Структура проекта и основные файлы

| Файл или каталог | Назначение |
|---|---|
| [settings.gradle.kts](../../settings.gradle.kts) | Задаёт имя Gradle-проекта, подключает модуль `:composeApp` и задаёт репозитории плагинов и зависимостей. |
| [build.gradle.kts](../../build.gradle.kts) | Объявляет плагины на уровне корневого проекта. |
| [gradle/libs.versions.toml](../../gradle/libs.versions.toml) | Хранит версии Kotlin, Compose, Android Gradle Plugin и параметры Android SDK. Для модуля установлены `minSdk 24`, `compileSdk 35` и `targetSdk 35`. |
| [composeApp/build.gradle.kts](../../composeApp/build.gradle.kts) | Настраивает платформы, зависимости и Android-сборку модуля. |
| [AndroidManifest.xml](../../composeApp/src/androidMain/AndroidManifest.xml) | Описывает приложение и регистрирует `MainActivity` как экран запуска через `MAIN` и `LAUNCHER`. |
| [MainActivity.kt](../../composeApp/src/androidMain/kotlin/org/example/project/MainActivity.kt) | Точка входа Android. В `onCreate` вызов `setContent { App() }` устанавливает интерфейс Compose. |
| [App.kt](../../composeApp/src/commonMain/kotlin/org/example/project/App.kt) | Общий экран приложения. Функция `App()` описывает заголовок и кнопку, а состояние `showContent` управляет видимостью результата. |
| [Greeting.kt](../../composeApp/src/commonMain/kotlin/org/example/project/Greeting.kt) и [Platform.android.kt](../../composeApp/src/androidMain/kotlin/org/example/project/Platform.android.kt) | Общий класс формирует приветствие. Android-реализация передаёт в него уровень API устройства. |
| [commonMain/composeResources](../../composeApp/src/commonMain/composeResources) | Общие ресурсы интерфейса, в том числе логотип Compose для демонстрации. |

В `src/commonMain` размещён общий код, а в `src/androidMain` находятся Android-код, манифест и платформенные ресурсы. В этом же репозитории Flutter-магазин имеет собственную точку входа `lib/core/main.dart` и отдельный Gradle-проект в `android/`.

## 4. Запуск исходного проекта

Эмулятор `emulator-5554`, Android 17 (API 37), x86_64. Команда запуска вернула `Status: ok`. На стартовом экране была кнопка `Click me!`.

```powershell
adb -s emulator-5554 shell am start -W -n org.example.project/.MainActivity
```

[Скриншот исходного интерфейса](before.png)

## 5. Изменение интерфейса и повторный запуск

В `App.kt` добавлен заголовок «Bubble Tea» и изменена подпись кнопки. «Проверить запуск» раскрывает изображение и приветствие, «Скрыть результат» сворачивает их. Изменение состояния `showContent` обновляет экран Compose.

Задача Gradle `:composeApp:assembleDebug` завершилась успешно. Обновлённый APK установлен на тот же эмулятор. На экране появились заголовок и кнопка «Проверить запуск». Нажатие показало логотип и строку `Compose: Hello, Android 37!`, а кнопка «Скрыть результат» свернула их. Холодный перезапуск вернул `Status: ok` и снова открыл изменённый экран.

[Скриншот изменённого интерфейса после нажатия кнопки](after.png)

Для повторения откройте корневой Gradle-проект репозитория в Android Studio, выберите Android-конфигурацию модуля `composeApp` и эмулятор. Нажмите **Run**, внесите изменение в `App.kt` и снова нажмите **Run**. Из корня проекта можно собрать APK командой `.\gradlew.bat :composeApp:assembleDebug`.
