# orgNIZWE Android — Life Organizer

Wersja aplikacji orgNIZWE na Androida, zbudowana w Flutter.

## Funkcje

- Ekran „Dzisiaj” z powitaniem, zadaniami, wydarzeniami i nawykami
- Zadania z priorytetami i terminami
- Kalendarz miesięczny i dzienny
- Nawyki z serią dni i procentem realizacji
- Lista zakupów
- Notatki i organizacja życia
- Personalizacja (ciemny motyw, imię użytkownika)

## Jak uruchomić

1. Zainstaluj Flutter: https://docs.flutter.dev/get-started/install
2. Wejdź do folderu `android_app`
3. Uruchom:
   ```bash
   flutter pub get
   flutter run
   ```

## Jak zbudować APK / AAB

```bash
flutter build apk --release
flutter build appbundle --release
```

## Jak wysłać do Google Play

1. Utwórz konto Google Play Console
2. Wygeneruj podpisany klucz:
   ```bash
   keytool -genkey -v -keystore orgnizwe-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias orgnizwe
   ```
3. Skonfiguruj signing w `android/app/build.gradle`
4. Wgraj AAB do Google Play Console
