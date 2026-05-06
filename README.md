# Займы 24/7

Каталог CPA-офферов микрофинансовых организаций. Состоит из двух частей:

| Каталог  | Описание                                                          | Стек                       |
|----------|-------------------------------------------------------------------|----------------------------|
| `mobile/`| Мобильное приложение для Google Play                              | Flutter (Dart) + Firebase  |
| `admin/` | Веб-админка для управления офферами и контентом                   | Next.js 15 + TypeScript    |

Бэкенд — **Firebase**: Firestore (контент и офферы), Storage (логотипы), Auth (вход админа).

> Исходное ТЗ: см. `Техническое_задание:_мобильное_приложение_«Займы_2.txt`
> Дизайн-макет: `app.fig` (открывается в Figma).

---

## 1. Подготовка Firebase

1. Создайте проект в [Firebase Console](https://console.firebase.google.com/).
2. Включите сервисы:
   - **Authentication** → Sign-in method → **Email/Password**.
   - **Firestore Database** (production mode).
   - **Storage**.
3. В Authentication создайте пользователя-администратора (e-mail + пароль).
4. Залейте правила безопасности из репозитория:
   ```
   firebase deploy --only firestore:rules,storage
   ```
   (или скопируйте содержимое `firestore.rules` и `storage.rules` через консоль)
5. Создайте документ `content/app` (можно вручную через консоль — поля заполнятся после первого сохранения из админки).

---

## 2. Админка (`admin/`)

```bash
cd admin
cp .env.example .env.local        # заполните значениями из Firebase Console → Project settings → Web app
npm install
npm run dev                       # http://localhost:3000
```

Сборка для продакшена:
```bash
npm run build
npm start
```
Деплой удобно делать на Vercel/Firebase Hosting — переменные `NEXT_PUBLIC_FIREBASE_*` пробрасывайте в окружение.

Возможности:
- Логин по email/password (Firebase Auth).
- CRUD офферов: название, слоган, сумма (₽), срок (дн.), возраст, логотип (загрузка в Firebase Storage), URL.
- Drag-and-drop сортировка — порядок сохраняется в поле `order` и используется приложением.
- Редактирование текстов: заголовки/подзаголовки главной и рейтинга, тексты onboarding, контакты.

---

## 3. Мобильное приложение (`mobile/`)

### Требования
- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.19
- Android SDK + JDK 17 (для сборки под Google Play)

### Первичная настройка

```bash
cd mobile

# 1) Сгенерировать недостающую обвязку (gradle wrapper, MainActivity.kt, иконки и т.д.)
flutter create --project-name zaymy247 --org ru.zaymy247 --platforms android .

# 2) Установить зависимости
flutter pub get

# 3) Подключить Firebase к проекту
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id>
# команда перепишет lib/firebase_options.dart и положит android/app/google-services.json
```

После `flutterfire configure` добавьте плагин Google Services в `android/app/build.gradle` —
раскомментируйте строку `id "com.google.gms.google-services"` в блоке `plugins {}`,
и в `android/build.gradle` добавьте классpath, как просит инструкция flutterfire.

### Запуск в эмуляторе

```bash
flutter run
```

При первом запуске показывается splash → onboarding (3 слайда) → основное приложение с нижней навигацией:
**Главная / Рейтинг / Калькулятор / Контакты**. При повторных запусках onboarding не показывается.

### Тесты и линт
```bash
flutter analyze
flutter test
```

### Релизная сборка для Google Play

1. Создайте upload-ключ:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Создайте `mobile/android/key.properties` (он уже в `.gitignore`):
   ```
   storeFile=/абсолютный/путь/upload-keystore.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
3. Соберите Android App Bundle:
   ```bash
   flutter build appbundle --release
   # → mobile/build/app/outputs/bundle/release/app-release.aab
   ```
4. Залейте `.aab` в [Google Play Console](https://play.google.com/console) → Internal testing / Production.

### Что нужно подготовить для публикации в Play (вручную)
- Аккаунт разработчика Google Play ($25 разово).
- Иконку приложения и featured graphic (можно сгенерировать в Figma из `app.fig`).
- Скриншоты экранов (минимум 2 для телефона).
- Краткое и полное описание на русском.
- Политику конфиденциальности (URL обязателен) — приложение использует Firebase, упомяните это.
- Заполненную декларацию о данных (Data safety) — Firebase собирает аналитику/ID устройства.

---

## 4. Структура данных в Firestore

```
content/app          ← документ с текстами
  homeTitle, homeSubtitle
  ratingTitle, ratingSubtitle
  contactsText
  onboarding: [{ title, text }, ...]

offers/{auto-id}     ← коллекция офферов
  name, slogan, age, logoUrl, url
  amount  (number, ₽)
  term    (number, дн.)
  order   (number — управляет позицией в списке)
```

Мобильное приложение читает `offers` отсортированными по `order`, отображает по 6 штук + кнопку
«Показать ещё». Админка пишет туда же и обновляет `order` через batched-write при drag-and-drop.

---

## 5. Что НЕ входит в этот репозиторий
- Реальный Firebase-проект (создаёте вы — он привязан к вашей организации).
- Релизный keystore и `key.properties`.
- iOS-сборка (по ТЗ только Google Play).
- Файлы Play Console (скриншоты, описание, политика).
- Попиксельное соответствие Figma-макету: реализован общий стиль и структура, точная сверка с `app.fig` делается на этапе UI-полировки.
